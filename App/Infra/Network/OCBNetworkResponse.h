#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBNetworkResponse : NSObject

@property (nonatomic, copy, readonly) NSString *requestIdentifier;
@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *headers;
@property (nonatomic, strong, nullable, readonly) id responseObject;
@property (nonatomic, strong, nullable, readonly) NSData *rawData;
@property (nonatomic, assign, readonly, getter=isSuccess) BOOL success;
@property (nonatomic, assign, readonly) BOOL hasBusinessEnvelope;
@property (nonatomic, assign, readonly, getter=isBusinessSuccess) BOOL businessSuccess;
@property (nonatomic, copy, nullable, readonly) NSNumber *businessCode;
@property (nonatomic, copy, nullable, readonly) NSString *businessMessage;
@property (nonatomic, strong, nullable, readonly) id businessData;

- (instancetype)initWithRequestIdentifier:(NSString *)requestIdentifier
                               statusCode:(NSInteger)statusCode
                                  headers:(nullable NSDictionary<NSString *, id> *)headers
                           responseObject:(nullable id)responseObject
                                  rawData:(nullable NSData *)rawData NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
