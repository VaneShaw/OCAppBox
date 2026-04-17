#import <Foundation/Foundation.h>

#import "OCBAutoRegister.h"

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;
@class OCBNetworkResponse;
@class OCBRequest;
@protocol OCBLogging;
@protocol OCBNetworking;
@protocol OCBRemoteConfigProviding;

typedef void (^OCBAPIServiceCompletion)(id _Nullable data,
                                        OCBNetworkResponse * _Nullable response,
                                        NSError * _Nullable error);

@interface OCBBaseAPIService : NSObject <OCBAppContextServiceFactory>

@property (nonatomic, weak, readonly) OCBAppContext *appContext;
@property (nonatomic, strong, readonly) id<OCBNetworking> networking;
@property (nonatomic, strong, readonly) id<OCBLogging> logger;
@property (nonatomic, strong, nullable, readonly) id<OCBRemoteConfigProviding> remoteConfig;

- (instancetype)initWithAppContext:(OCBAppContext *)appContext NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)sendRequest:(OCBRequest *)request completion:(nullable OCBAPIServiceCompletion)completion;
- (void)GET:(NSString *)path
 parameters:(nullable NSDictionary<NSString *, id> *)parameters
 completion:(nullable OCBAPIServiceCompletion)completion;
- (void)POST:(NSString *)path
  parameters:(nullable NSDictionary<NSString *, id> *)parameters
  completion:(nullable OCBAPIServiceCompletion)completion;
- (void)PUT:(NSString *)path
 parameters:(nullable NSDictionary<NSString *, id> *)parameters
 completion:(nullable OCBAPIServiceCompletion)completion;
- (void)DELETE:(NSString *)path
    parameters:(nullable NSDictionary<NSString *, id> *)parameters
    completion:(nullable OCBAPIServiceCompletion)completion;
- (nullable NSString *)messageForError:(nullable NSError *)error defaultValue:(nullable NSString *)defaultValue;
- (nullable id)responseDataForResponse:(nullable OCBNetworkResponse *)response;
- (nullable NSError *)normalizedError:(nullable NSError *)error response:(nullable OCBNetworkResponse *)response;

@end

NS_ASSUME_NONNULL_END
