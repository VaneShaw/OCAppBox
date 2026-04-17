#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OCBHTTPMethod) {
    OCBHTTPMethodGET = 0,
    OCBHTTPMethodPOST = 1,
    OCBHTTPMethodPUT = 2,
    OCBHTTPMethodDELETE = 3,
};

typedef NS_ENUM(NSInteger, OCBRequestSerializerType) {
    OCBRequestSerializerTypeJSON = 0,
    OCBRequestSerializerTypeFormURLEncoded = 1,
};

typedef NS_ENUM(NSInteger, OCBResponseSerializerType) {
    OCBResponseSerializerTypeJSON = 0,
    OCBResponseSerializerTypeHTTP = 1,
};

@interface OCBRequest : NSObject

@property (nonatomic, copy, readonly) NSString *requestIdentifier;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, assign, readonly) OCBHTTPMethod method;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *parameters;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, assign, readonly) OCBRequestSerializerType requestSerializerType;
@property (nonatomic, assign, readonly) OCBResponseSerializerType responseSerializerType;
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;

+ (instancetype)requestWithPath:(NSString *)path method:(OCBHTTPMethod)method;
+ (instancetype)requestWithPath:(NSString *)path
                         method:(OCBHTTPMethod)method
                     parameters:(nullable NSDictionary<NSString *, id> *)parameters;
+ (instancetype)requestWithPath:(NSString *)path
                         method:(OCBHTTPMethod)method
                     parameters:(nullable NSDictionary<NSString *, id> *)parameters
                        headers:(nullable NSDictionary<NSString *, NSString *> *)headers;
+ (instancetype)formRequestWithPath:(NSString *)path
                             method:(OCBHTTPMethod)method
                         parameters:(nullable NSDictionary<NSString *, id> *)parameters
                            headers:(nullable NSDictionary<NSString *, NSString *> *)headers;
+ (instancetype)GET:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters;
+ (instancetype)POST:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters;
+ (instancetype)PUT:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters;
+ (instancetype)DELETE:(NSString *)path parameters:(nullable NSDictionary<NSString *, id> *)parameters;

- (instancetype)initWithPath:(NSString *)path
                      method:(OCBHTTPMethod)method
                  parameters:(nullable NSDictionary<NSString *, id> *)parameters
                     headers:(nullable NSDictionary<NSString *, NSString *> *)headers
       requestSerializerType:(OCBRequestSerializerType)requestSerializerType
      responseSerializerType:(OCBResponseSerializerType)responseSerializerType
             timeoutInterval:(NSTimeInterval)timeoutInterval NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPath:(NSString *)path
                      method:(OCBHTTPMethod)method
                  parameters:(nullable NSDictionary<NSString *, id> *)parameters
                     headers:(nullable NSDictionary<NSString *, NSString *> *)headers
             timeoutInterval:(NSTimeInterval)timeoutInterval;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
