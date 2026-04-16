#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBRequest;

typedef void (^OCBNetworkCompletion)(NSData * _Nullable data,
                                     NSURLResponse * _Nullable response,
                                     NSError * _Nullable error);

@protocol OCBNetworking <NSObject>

- (void)sendRequest:(OCBRequest *)request completion:(OCBNetworkCompletion)completion;

@end

@interface OCBNetworkClient : NSObject <OCBNetworking>

@property (nonatomic, strong, nullable) NSURL *baseURL;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *commonHeaders;

- (instancetype)initWithBaseURL:(nullable NSURL *)baseURL NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
