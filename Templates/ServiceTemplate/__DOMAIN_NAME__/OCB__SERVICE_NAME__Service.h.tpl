#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCBLogging;
@protocol OCBStorageProviding;

FOUNDATION_EXPORT NSString * const OCB__SERVICE_NAME__DidChangeNotification;

@protocol OCB__SERVICE_NAME__Providing <NSObject>

- (NSDictionary<NSString *, id> *)allValues;
- (nullable id)stateValueForKey:(NSString *)key;
- (void)applyState:(NSDictionary<NSString *, id> *)state;
- (void)setStateValue:(nullable id)value forKey:(NSString *)key;

@end

@interface OCB__SERVICE_NAME__Service : NSObject <OCB__SERVICE_NAME__Providing>

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
