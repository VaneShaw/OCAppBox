#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBRequest;
@class OCBNetworkResponse;

typedef void (^OCBNetworkCompletion)(OCBNetworkResponse * _Nullable response,
                                     NSError * _Nullable error);

@protocol OCBNetworking <NSObject>

- (void)sendRequest:(OCBRequest *)request completion:(OCBNetworkCompletion)completion;
- (void)setBaseURL:(nullable NSURL *)baseURL forEnvironment:(NSString *)environment;
- (nullable NSURL *)baseURLForEnvironment:(NSString *)environment;
- (NSArray<NSString *> *)registeredEnvironments;
- (void)useEnvironment:(NSString *)environment;
- (NSString *)currentEnvironment;

@end

@interface OCBNetworkClient : NSObject <OCBNetworking>

@property (nonatomic, strong, nullable) NSURL *baseURL;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *commonHeaders;
@property (nonatomic, copy, readonly) NSString *currentEnvironment;

- (instancetype)initWithBaseURL:(nullable NSURL *)baseURL NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
