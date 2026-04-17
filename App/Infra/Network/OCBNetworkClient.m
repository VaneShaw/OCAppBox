#import "OCBNetworkClient.h"

#if __has_include(<AFNetworking/AFHTTPSessionManager.h>)
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFURLResponseSerialization.h>
#import <objc/runtime.h>
#define OCB_HAS_AFNETWORKING 1
#else
#define OCB_HAS_AFNETWORKING 0
#endif

#import "OCBNetworkError.h"
#import "OCBNetworkResponse.h"
#import "OCBRequest.h"

@interface OCBNetworkClient ()

@property (nonatomic, copy, readwrite) NSString *currentEnvironment;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSURL *> *baseURLsByEnvironment;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation OCBNetworkClient

#if OCB_HAS_AFNETWORKING
static void *OCBNetworkClientTaskManagerKey = &OCBNetworkClientTaskManagerKey;
#endif

- (instancetype)init
{
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(nullable NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _commonHeaders = @{};
        _currentEnvironment = @"development";
        _baseURLsByEnvironment = [[NSMutableDictionary alloc] init];
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)sendRequest:(OCBRequest *)request completion:(OCBNetworkCompletion)completion
{
    if (request.path.length == 0) {
        [self dispatchCompletion:completion
                        response:nil
                           error:[OCBNetworkError invalidRequestWithReason:@"Request path can not be empty."]];
        return;
    }

    NSURL *resolvedURL = [self requestURLForPath:request.path];
    if (resolvedURL == nil) {
        [self dispatchCompletion:completion
                        response:nil
                           error:[OCBNetworkError invalidURLForPath:request.path]];
        return;
    }

#if OCB_HAS_AFNETWORKING
    NSURL *resolvedBaseURL = [self resolvedBaseURL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self isAbsoluteRequestPath:request.path] ? nil : resolvedBaseURL];
    [self configureManager:manager forRequest:request];

    NSString *URLString = [self isAbsoluteRequestPath:request.path] ? resolvedURL.absoluteString : request.path;
    NSDictionary<NSString *, NSString *> *headers = [self mergedHeadersWithRequestHeaders:request.headers];

    NSURLSessionDataTask *task = [manager dataTaskWithHTTPMethod:[self stringForHTTPMethod:request.method]
                                                       URLString:URLString
                                                      parameters:request.parameters
                                                         headers:headers
                                                  uploadProgress:nil
                                                downloadProgress:nil
                                                         success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        OCBNetworkResponse *networkResponse = [self networkResponseWithRequest:request
                                                                      response:httpResponse
                                                                responseObject:responseObject
                                                                       rawData:[responseObject isKindOfClass:[NSData class]] ? responseObject : nil];
        NSError *businessError = [self businessErrorFromResponse:networkResponse];
        [self dispatchCompletion:completion response:networkResponse error:businessError];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSData *responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *serializationError = nil;
        id responseObject = [self responseObjectFromResponseData:responseData request:request error:&serializationError];
        if (serializationError != nil) {
            [self dispatchCompletion:completion
                            response:nil
                               error:[OCBNetworkError serializationFailedWithUnderlyingError:serializationError]];
            return;
        }

        OCBNetworkResponse *networkResponse = [self networkResponseWithRequest:request
                                                                      response:httpResponse
                                                                responseObject:responseObject
                                                                       rawData:responseData];
        NSError *wrappedError = [self wrappedErrorFromError:error
                                                 statusCode:httpResponse.statusCode
                                             responseObject:responseObject];
        [self dispatchCompletion:completion response:networkResponse error:wrappedError];
    }];

    objc_setAssociatedObject(task, OCBNetworkClientTaskManagerKey, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [task resume];
#else
    NSError *requestError = nil;
    NSMutableURLRequest *urlRequest = [self URLRequestForRequest:request resolvedURL:resolvedURL error:&requestError];
    if (requestError != nil) {
        [self dispatchCompletion:completion response:nil error:requestError];
        return;
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest
                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
        NSError *serializationError = nil;
        id responseObject = [self responseObjectFromResponseData:data request:request error:&serializationError];
        OCBNetworkResponse *networkResponse = [self networkResponseWithRequest:request
                                                                      response:httpResponse
                                                                responseObject:responseObject
                                                                       rawData:data];

        NSError *finalError = nil;
        if (serializationError != nil) {
            finalError = [OCBNetworkError serializationFailedWithUnderlyingError:serializationError];
        } else if (error != nil) {
            finalError = [self wrappedErrorFromError:error
                                          statusCode:httpResponse.statusCode
                                      responseObject:responseObject];
        } else if (httpResponse.statusCode >= 400) {
            finalError = [OCBNetworkError httpStatusError:httpResponse.statusCode
                                            responseObject:responseObject
                                           underlyingError:nil];
        } else {
            finalError = [self businessErrorFromResponse:networkResponse];
        }

        [self dispatchCompletion:completion response:networkResponse error:finalError];
    }];
    [task resume];
#endif
}

- (void)setBaseURL:(nullable NSURL *)baseURL forEnvironment:(NSString *)environment
{
    if (environment.length == 0) {
        return;
    }

    if (baseURL != nil) {
        self.baseURLsByEnvironment[environment] = baseURL;
    } else {
        [self.baseURLsByEnvironment removeObjectForKey:environment];
    }
}

- (nullable NSURL *)baseURLForEnvironment:(NSString *)environment
{
    if (environment.length == 0) {
        return nil;
    }

    return self.baseURLsByEnvironment[environment];
}

- (NSArray<NSString *> *)registeredEnvironments
{
    NSMutableOrderedSet<NSString *> *environmentSet = [[NSMutableOrderedSet alloc] initWithArray:[self.baseURLsByEnvironment.allKeys sortedArrayUsingSelector:@selector(compare:)]];
    if (self.currentEnvironment.length > 0) {
        [environmentSet addObject:self.currentEnvironment];
    }
    return environmentSet.array;
}

- (void)useEnvironment:(NSString *)environment
{
    self.currentEnvironment = environment.length > 0 ? [environment copy] : @"development";
}

- (nullable NSURL *)resolvedBaseURL
{
    NSURL *mappedBaseURL = [self baseURLForEnvironment:self.currentEnvironment];
    return mappedBaseURL ?: self.baseURL;
}

- (nullable NSURL *)requestURLForPath:(NSString *)path
{
    if (path.length == 0) {
        return nil;
    }

    if ([self isAbsoluteRequestPath:path]) {
        return [NSURL URLWithString:path];
    }

    NSURL *resolvedBaseURL = [self resolvedBaseURL];
    if (resolvedBaseURL == nil) {
        return nil;
    }

    return [NSURL URLWithString:path relativeToURL:resolvedBaseURL];
}

- (BOOL)isAbsoluteRequestPath:(NSString *)path
{
    NSURL *candidateURL = [NSURL URLWithString:path];
    return candidateURL.scheme.length > 0 && candidateURL.host.length > 0;
}

- (NSDictionary<NSString *, NSString *> *)mergedHeadersWithRequestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders
{
    NSMutableDictionary<NSString *, NSString *> *headers = [[NSMutableDictionary alloc] init];
    if (self.currentEnvironment.length > 0) {
        headers[@"X-OCB-Environment"] = self.currentEnvironment;
    }
    [headers addEntriesFromDictionary:self.commonHeaders];
    [headers addEntriesFromDictionary:requestHeaders];
    return [headers copy];
}

#if OCB_HAS_AFNETWORKING
- (void)configureManager:(AFHTTPSessionManager *)manager forRequest:(OCBRequest *)request
{
    manager.requestSerializer = [self requestSerializerForType:request.requestSerializerType];
    manager.requestSerializer.timeoutInterval = request.timeoutInterval;
    manager.responseSerializer = [self responseSerializerForType:request.responseSerializerType];
}

- (AFHTTPRequestSerializer *)requestSerializerForType:(OCBRequestSerializerType)serializerType
{
    switch (serializerType) {
        case OCBRequestSerializerTypeFormURLEncoded:
            return [AFHTTPRequestSerializer serializer];
        case OCBRequestSerializerTypeJSON:
            return [AFJSONRequestSerializer serializer];
    }

    return [AFJSONRequestSerializer serializer];
}

- (AFHTTPResponseSerializer *)responseSerializerForType:(OCBResponseSerializerType)serializerType
{
    switch (serializerType) {
        case OCBResponseSerializerTypeHTTP:
            return [AFHTTPResponseSerializer serializer];
        case OCBResponseSerializerTypeJSON: {
            AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
            serializer.acceptableContentTypes = [NSSet setWithArray:@[
                @"application/json",
                @"text/json",
                @"text/javascript",
                @"text/plain",
                @"text/html"
            ]];
            return serializer;
        }
    }

    return [AFJSONResponseSerializer serializer];
}
#endif

- (nullable id)responseObjectFromResponseData:(nullable NSData *)responseData
                                      request:(OCBRequest *)request
                                        error:(NSError * _Nullable __autoreleasing *)error
{
    if (responseData.length == 0) {
        return nil;
    }

    if (request.responseSerializerType == OCBResponseSerializerTypeHTTP) {
        return responseData;
    }

    return [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:error];
}

- (nullable OCBNetworkResponse *)networkResponseWithRequest:(OCBRequest *)request
                                                   response:(nullable NSHTTPURLResponse *)response
                                             responseObject:(nullable id)responseObject
                                                    rawData:(nullable NSData *)rawData
{
    if (response == nil && responseObject == nil && rawData == nil) {
        return nil;
    }

    return [[OCBNetworkResponse alloc] initWithRequestIdentifier:request.requestIdentifier
                                                      statusCode:response.statusCode
                                                         headers:response.allHeaderFields
                                                  responseObject:responseObject
                                                         rawData:rawData];
}

- (nullable NSMutableURLRequest *)URLRequestForRequest:(OCBRequest *)request
                                           resolvedURL:(NSURL *)resolvedURL
                                                 error:(NSError * _Nullable __autoreleasing *)error
{
    NSURL *finalURL = resolvedURL;
    if (request.method == OCBHTTPMethodGET && request.parameters.count > 0) {
        finalURL = [self URLByAppendingQueryParameters:request.parameters toURL:resolvedURL];
    }

    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:finalURL];
    urlRequest.HTTPMethod = [self stringForHTTPMethod:request.method];
    urlRequest.timeoutInterval = request.timeoutInterval;

    NSDictionary<NSString *, NSString *> *headers = [self mergedHeadersWithRequestHeaders:request.headers];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [urlRequest setValue:obj forHTTPHeaderField:key];
    }];

    if (request.method == OCBHTTPMethodGET || request.parameters.count == 0) {
        return urlRequest;
    }

    if (request.requestSerializerType == OCBRequestSerializerTypeFormURLEncoded) {
        NSData *bodyData = [[self formEncodedQueryStringForParameters:request.parameters] dataUsingEncoding:NSUTF8StringEncoding];
        urlRequest.HTTPBody = bodyData;
        if ([urlRequest valueForHTTPHeaderField:@"Content-Type"].length == 0) {
            [urlRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        }
        return urlRequest;
    }

    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:request.parameters options:0 error:error];
    if (bodyData == nil) {
        return nil;
    }

    urlRequest.HTTPBody = bodyData;
    if ([urlRequest valueForHTTPHeaderField:@"Content-Type"].length == 0) {
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }

    return urlRequest;
}

- (NSURL *)URLByAppendingQueryParameters:(NSDictionary<NSString *, id> *)parameters toURL:(NSURL *)url
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSMutableArray<NSURLQueryItem *> *items = [[NSMutableArray alloc] initWithArray:components.queryItems ?: @[]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [items addObject:[[NSURLQueryItem alloc] initWithName:key value:[obj description]]];
    }];
    components.queryItems = items;
    return components.URL ?: url;
}

- (NSString *)formEncodedQueryStringForParameters:(NSDictionary<NSString *, id> *)parameters
{
    NSMutableArray<NSString *> *parts = [[NSMutableArray alloc] init];
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@":#[]@!$&'()*+,;="] invertedSet];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        NSString *escapedKey = [[key description] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet] ?: key;
        NSString *escapedValue = [[obj description] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet] ?: [obj description];
        [parts addObject:[NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue]];
    }];
    return [parts componentsJoinedByString:@"&"];
}

- (NSError *)wrappedErrorFromError:(NSError *)error
                        statusCode:(NSInteger)statusCode
                    responseObject:(nullable id)responseObject
{
    if (statusCode >= 400) {
        return [OCBNetworkError httpStatusError:statusCode
                                  responseObject:responseObject
                                 underlyingError:error];
    }

#if OCB_HAS_AFNETWORKING
    if ([error.domain isEqualToString:AFURLResponseSerializationErrorDomain]) {
        return [OCBNetworkError unexpectedResponseWithResponseObject:responseObject];
    }
#endif

    return error;
}

- (nullable NSError *)businessErrorFromResponse:(nullable OCBNetworkResponse *)response
{
    if (response == nil || !response.isSuccess || !response.hasBusinessEnvelope || response.isBusinessSuccess) {
        return nil;
    }

    return [OCBNetworkError businessErrorWithCode:response.businessCode
                                          message:response.businessMessage
                                   responseObject:response.responseObject
                                             data:response.businessData];
}

- (void)dispatchCompletion:(OCBNetworkCompletion)completion
                  response:(nullable OCBNetworkResponse *)response
                     error:(nullable NSError *)error
{
    if (completion == nil) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        completion(response, error);
    });
}

- (NSString *)stringForHTTPMethod:(OCBHTTPMethod)method
{
    switch (method) {
        case OCBHTTPMethodGET:
            return @"GET";
        case OCBHTTPMethodPOST:
            return @"POST";
        case OCBHTTPMethodPUT:
            return @"PUT";
        case OCBHTTPMethodDELETE:
            return @"DELETE";
    }

    return @"GET";
}

@end
