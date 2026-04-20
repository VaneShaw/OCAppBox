#import "OCBConfigCenter.h"

static NSString *OCBConfigStorageKey(NSString *key)
{
    return [NSString stringWithFormat:@"ocb.localConfig.%@", key];
}

@interface OCBConfigCenter ()

@property (nonatomic, strong, readonly) NSUserDefaults *defaults;

@end

@implementation OCBConfigCenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (nullable id)objectForKey:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }
    return [self.defaults objectForKey:OCBConfigStorageKey(key)];
}

- (void)setObject:(nullable id)object forKey:(NSString *)key
{
    if (key.length == 0) {
        return;
    }
    NSString *storageKey = OCBConfigStorageKey(key);
    if (object == nil) {
        [self.defaults removeObjectForKey:storageKey];
        return;
    }
    [self.defaults setObject:object forKey:storageKey];
}

- (void)removeObjectForKey:(NSString *)key
{
    [self setObject:nil forKey:key];
}

- (nullable NSString *)stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSURL class]]) {
        return [value description];
    }
    return defaultValue;
}

- (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return defaultValue;
}

- (NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return defaultValue;
}

@end
