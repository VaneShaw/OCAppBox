#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OCBHTTPMethod) {
    OCBHTTPMethodGET = 0,
    OCBHTTPMethodPOST = 1,
    OCBHTTPMethodPUT = 2,
    OCBHTTPMethodDELETE = 3,
};

@interface OCBRequest : NSObject

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, assign, readonly) OCBHTTPMethod method;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *parameters;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;

- (instancetype)initWithPath:(NSString *)path
                      method:(OCBHTTPMethod)method
                  parameters:(nullable NSDictionary<NSString *, id> *)parameters
                     headers:(nullable NSDictionary<NSString *, NSString *> *)headers
             timeoutInterval:(NSTimeInterval)timeoutInterval NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
