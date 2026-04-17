#import "OCBRemoteConfigService.h"

#import "OCBCacheCenter.h"
#import "NSDictionary+OCBAdditions.h"
#import "OCBLogger.h"

NSString * const OCBRemoteConfigDidChangeNotification = @"OCBRemoteConfigDidChangeNotification";

static NSString * const OCBRemoteConfigStorageKey = @"service.remoteConfig.values";

@interface OCBRemoteConfigService ()

@property (nonatomic, strong) id<OCBStorageProviding> storage;
@property (nonatomic, strong) id<OCBLogging> logger;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *values;

@end

@implementation OCBRemoteConfigService

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger
{
    self = [super init];
    if (self) {
        _storage = storage;
        _logger = logger;

        id storedObject = [storage diskObjectForKey:OCBRemoteConfigStorageKey];
        if ([storedObject isKindOfClass:[NSDictionary class]]) {
            _values = [((NSDictionary *)storedObject) mutableCopy];
        } else {
            _values = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)applyConfigDictionary:(NSDictionary<NSString *,id> *)config
{
    if (config.count == 0) {
        return;
    }

    [self.values addEntriesFromDictionary:config];
    [self.storage setDiskObject:[self.values copy] forKey:OCBRemoteConfigStorageKey];
    [self.logger logWithLevel:OCBLogLevelInfo
                      message:[NSString stringWithFormat:@"Remote config updated with %lu keys.", (unsigned long)config.count]];

    [[NSNotificationCenter defaultCenter] postNotificationName:OCBRemoteConfigDidChangeNotification
                                                        object:self
                                                      userInfo:nil];
}

- (NSDictionary<NSString *,id> *)allValues
{
    return [self.values copy];
}

- (nullable NSString *)stringValueForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue
{
    return [self.values ocb_stringForKey:key defaultValue:defaultValue];
}

- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    return [self.values ocb_boolForKey:key defaultValue:defaultValue];
}

- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    return [self.values ocb_integerForKey:key defaultValue:defaultValue];
}

@end
