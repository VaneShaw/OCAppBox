#import "OCBPermissionService.h"

#import "OCBFoundationMacros.h"
#import "OCBCacheCenter.h"
#import "OCBLogger.h"

NSString * const OCBPermissionDidChangeNotification = @"OCBPermissionDidChangeNotification";
NSString * const OCBPermissionKeyUserInfoKey = @"permissionKey";
NSString * const OCBPermissionStatusUserInfoKey = @"permissionStatus";

static NSString * const OCBPermissionStorageKey = @"service.permission.statuses";

@interface OCBPermissionService ()

@property (nonatomic, strong) id<OCBStorageProviding> storage;
@property (nonatomic, strong) id<OCBLogging> logger;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *statuses;

@end

@implementation OCBPermissionService

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger
{
    self = [super init];
    if (self) {
        _storage = storage;
        _logger = logger;

        id storedObject = [storage diskObjectForKey:OCBPermissionStorageKey];
        if ([storedObject isKindOfClass:[NSDictionary class]]) {
            _statuses = [((NSDictionary *)storedObject) mutableCopy];
        } else {
            _statuses = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (OCBPermissionStatus)statusForPermission:(NSString *)permissionKey
{
    NSNumber *statusValue = self.statuses[permissionKey];
    return statusValue != nil ? (OCBPermissionStatus)statusValue.integerValue : OCBPermissionStatusUnknown;
}

- (void)requestPermission:(NSString *)permissionKey
               completion:(void (^)(OCBPermissionStatus status))completion
{
    OCBPermissionStatus currentStatus = [self statusForPermission:permissionKey];

    [self.logger logWithLevel:OCBLogLevelInfo
                      message:[NSString stringWithFormat:@"Request permission: %@", permissionKey]];

    OCB_SAFE_BLOCK(completion, currentStatus);
}

- (void)updateStatus:(OCBPermissionStatus)status forPermission:(NSString *)permissionKey
{
    if (permissionKey.length == 0) {
        return;
    }

    self.statuses[permissionKey] = @(status);
    [self.storage setDiskObject:[self.statuses copy] forKey:OCBPermissionStorageKey];
    [self.logger logWithLevel:OCBLogLevelDebug
                      message:[NSString stringWithFormat:@"Permission %@ updated to %ld", permissionKey, (long)status]];

    [[NSNotificationCenter defaultCenter] postNotificationName:OCBPermissionDidChangeNotification
                                                        object:self
                                                      userInfo:@{
        OCBPermissionKeyUserInfoKey: permissionKey,
        OCBPermissionStatusUserInfoKey: @(status)
    }];
}

@end
