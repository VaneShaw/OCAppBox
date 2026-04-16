#import "OCBNetworkClient.h"

#import "OCBRequest.h"

@interface OCBNetworkClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation OCBNetworkClient

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
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (void)sendRequest:(OCBRequest *)request completion:(OCBNetworkCompletion)completion
{
    NSURL *url = [self URLForRequest:request];
    if (url == nil) {
        if (completion != nil) {
            NSError *error = [NSError errorWithDomain:@"com.ocappbox.network"
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: @"Invalid request URL."}];
            completion(nil, nil, error);
        }
        return;
    }

    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.HTTPMethod = [self stringForHTTPMethod:request.method];
    urlRequest.timeoutInterval = request.timeoutInterval;

    NSMutableDictionary<NSString *, NSString *> *headers = [self.commonHeaders mutableCopy];
    [headers addEntriesFromDictionary:request.headers];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [urlRequest setValue:obj forHTTPHeaderField:key];
    }];

    if (request.method != OCBHTTPMethodGET && request.parameters.count > 0) {
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:request.parameters options:0 error:nil];
        if (bodyData != nil) {
            urlRequest.HTTPBody = bodyData;
            if ([urlRequest valueForHTTPHeaderField:@"Content-Type"].length == 0) {
                [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            }
        }
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion != nil) {
            completion(data, response, error);
        }
    }];
    [task resume];
}

- (nullable NSURL *)URLForRequest:(OCBRequest *)request
{
    if (request.path.length == 0) {
        return nil;
    }

    NSURL *url = [NSURL URLWithString:request.path relativeToURL:self.baseURL];
    if (url == nil) {
        return nil;
    }

    if (request.method != OCBHTTPMethodGET || request.parameters.count == 0) {
        return url;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSMutableArray<NSURLQueryItem *> *queryItems = [[NSMutableArray alloc] init];
    [request.parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [queryItems addObject:[[NSURLQueryItem alloc] initWithName:key value:[obj description]]];
    }];
    components.queryItems = queryItems;
    return components.URL;
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
