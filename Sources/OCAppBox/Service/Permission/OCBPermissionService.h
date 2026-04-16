#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCBLogging;
@protocol OCBStorageProviding;

typedef NS_ENUM(NSInteger, OCBPermissionStatus) {
    OCBPermissionStatusUnknown = 0,
    OCBPermissionStatusDenied = 1,
    OCBPermissionStatusAuthorized = 2,
    OCBPermissionStatusRestricted = 3,
};

FOUNDATION_EXPORT NSString * const OCBPermissionDidChangeNotification;
FOUNDATION_EXPORT NSString * const OCBPermissionKeyUserInfoKey;
FOUNDATION_EXPORT NSString * const OCBPermissionStatusUserInfoKey;

@protocol OCBPermissionProviding <NSObject>

- (OCBPermissionStatus)statusForPermission:(NSString *)permissionKey;
- (void)requestPermission:(NSString *)permissionKey
               completion:(void (^)(OCBPermissionStatus status))completion;
- (void)setMockStatus:(OCBPermissionStatus)status forPermission:(NSString *)permissionKey;

@end

@interface OCBPermissionService : NSObject <OCBPermissionProviding>

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
