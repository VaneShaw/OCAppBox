#import "OCBBaseAPIService.h"

#import "OCBAppContext.h"
#import "OCBFoundationMacros.h"
#import "OCBLogger.h"
#import "OCBNetworkClient.h"
#import "OCBNetworkError.h"
#import "OCBNetworkResponse.h"
#import "OCBRemoteConfigService.h"
#import "OCBRequest.h"
#import "OCBServiceRegistry.h"

@interface OCBBaseAPIService ()

@property (nonatomic, weak, readwrite) OCBAppContext *appContext;
@property (nonatomic, strong, readwrite) id<OCBNetworking> networking;
@property (nonatomic, strong, readwrite) id<OCBLogging> logger;
@property (nonatomic, strong, nullable, readwrite) id<OCBRemoteConfigProviding> remoteConfig;

@end

@implementation OCBBaseAPIService

+ (id)serviceWithAppContext:(OCBAppContext *)appContext
{
    return [[self alloc] initWithAppContext:appContext];
}

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
{
    self = [super init];
    if (self) {
        _appContext = appContext;
        _networking = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBNetworking)];
        _logger = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
        _remoteConfig = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBRemoteConfigProviding)];
    }
    return self;
}

- (void)sendRequest:(OCBRequest *)request completion:(nullable OCBAPIServiceCompletion)completion
{
    if (request == nil) {
        OCB_SAFE_BLOCK(completion,
                       nil,
                       nil,
                       [OCBNetworkError invalidRequestWithReason:@"Request can not be nil."]);
        return;
    }

    if (self.networking == nil) {
        OCB_SAFE_BLOCK(completion,
                       nil,
                       nil,
                       [OCBNetworkError invalidRequestWithReason:@"Networking service is unavailable."]);
        return;
    }

    [self.logger logWithLevel:OCBLogLevelDebug
                      message:[NSString stringWithFormat:@"API request %@ %@", [self stringForHTTPMethod:request.method], request.path]];

    OCB_WEAKIFY(self);
    [self.networking sendRequest:request completion:^(OCBNetworkResponse * _Nullable response, NSError * _Nullable error) {
        OCB_STRONGIFY(self);
        NSError *normalizedError = self != nil ? [self normalizedError:error response:response] : error;
        if (normalizedError != nil) {
            if (self != nil) {
                [self.logger logWithLevel:OCBLogLevelWarning
                                  message:[NSString stringWithFormat:@"API request failed %@ %@: %@",
                                           [self stringForHTTPMethod:request.method],
                                           request.path,
                                           [self messageForError:normalizedError defaultValue:@"Unknown error"] ?: @"Unknown error"]];
            }
            OCB_SAFE_BLOCK(completion, nil, response, normalizedError);
            return;
        }

        id responseData = self != nil ? [self responseDataForResponse:response] : response.businessData;
        OCB_SAFE_BLOCK(completion, responseData, response, nil);
    }];
}

- (void)GET:(NSString *)path
 parameters:(nullable NSDictionary<NSString *,id> *)parameters
 completion:(nullable OCBAPIServiceCompletion)completion
{
    [self sendRequest:[OCBRequest GET:path parameters:parameters] completion:completion];
}

- (void)POST:(NSString *)path
  parameters:(nullable NSDictionary<NSString *,id> *)parameters
  completion:(nullable OCBAPIServiceCompletion)completion
{
    [self sendRequest:[OCBRequest POST:path parameters:parameters] completion:completion];
}

- (void)PUT:(NSString *)path
 parameters:(nullable NSDictionary<NSString *,id> *)parameters
 completion:(nullable OCBAPIServiceCompletion)completion
{
    [self sendRequest:[OCBRequest PUT:path parameters:parameters] completion:completion];
}

- (void)DELETE:(NSString *)path
    parameters:(nullable NSDictionary<NSString *,id> *)parameters
    completion:(nullable OCBAPIServiceCompletion)completion
{
    [self sendRequest:[OCBRequest DELETE:path parameters:parameters] completion:completion];
}

- (void)GET:(NSString *)path
       page:(NSInteger)page
   pageSize:(NSInteger)pageSize
 parameters:(nullable NSDictionary<NSString *,id> *)parameters
 completion:(nullable OCBAPIServiceCompletion)completion
{
    NSMutableDictionary<NSString *, id> *mergedParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters ?: @{}];
    mergedParameters[[self pageNumberParameterKey]] = @(MAX(page, 1));
    mergedParameters[[self pageSizeParameterKey]] = @(MAX(pageSize, 1));
    [self sendRequest:[OCBRequest GET:path parameters:[mergedParameters copy]] completion:completion];
}

- (nullable NSString *)messageForError:(nullable NSError *)error defaultValue:(nullable NSString *)defaultValue
{
    if (error == nil) {
        return defaultValue;
    }

    NSString *businessMessage = error.userInfo[OCBNetworkErrorBusinessMessageUserInfoKey];
    if (businessMessage.length > 0) {
        return businessMessage;
    }

    if (error.localizedDescription.length > 0) {
        return error.localizedDescription;
    }

    return defaultValue;
}

- (nullable id)responseDataForResponse:(nullable OCBNetworkResponse *)response
{
    return response.businessData;
}

- (nullable NSError *)normalizedError:(nullable NSError *)error response:(nullable OCBNetworkResponse *)response
{
    return error;
}

- (NSString *)pageNumberParameterKey
{
    return @"page";
}

- (NSString *)pageSizeParameterKey
{
    return @"page_size";
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
