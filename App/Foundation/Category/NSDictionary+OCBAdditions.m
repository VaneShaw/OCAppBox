#import "NSDictionary+OCBAdditions.h"

#import "NSString+OCBAdditions.h"

@implementation NSDictionary (OCBAdditions)

- (nullable id)ocb_objectForKeyPath:(nullable NSString *)keyPath
{
    if (keyPath.length == 0) {
        return nil;
    }

    NSArray<NSString *> *components = [keyPath componentsSeparatedByString:@"."];
    id currentValue = self;
    for (NSString *component in components) {
        if (![currentValue isKindOfClass:[NSDictionary class]]) {
            return nil;
        }

        currentValue = ((NSDictionary *)currentValue)[component];
        if (currentValue == nil || currentValue == [NSNull null]) {
            return nil;
        }
    }

    return currentValue;
}

- (nullable NSString *)ocb_stringForKey:(id)key defaultValue:(nullable NSString *)defaultValue
{
    id value = self[key];
    if (value == nil || value == [NSNull null]) {
        return defaultValue;
    }

    return [NSString ocb_stringWithObject:value defaultValue:defaultValue];
}

- (nullable NSString *)ocb_stringForKeyPath:(nullable NSString *)keyPath defaultValue:(nullable NSString *)defaultValue
{
    id value = [self ocb_objectForKeyPath:keyPath];
    if (value == nil) {
        return defaultValue;
    }

    return [NSString ocb_stringWithObject:value defaultValue:defaultValue];
}

- (BOOL)ocb_boolForKey:(id)key defaultValue:(BOOL)defaultValue
{
    id value = self[key];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *normalizedValue = [[(NSString *)value ocb_trimmedString] lowercaseString];
        if ([normalizedValue isEqualToString:@"true"] || [normalizedValue isEqualToString:@"yes"]) {
            return YES;
        }
        if ([normalizedValue isEqualToString:@"false"] || [normalizedValue isEqualToString:@"no"]) {
            return NO;
        }
        return [normalizedValue boolValue];
    }

    return defaultValue;
}

- (BOOL)ocb_boolForKeyPath:(nullable NSString *)keyPath defaultValue:(BOOL)defaultValue
{
    id value = [self ocb_objectForKeyPath:keyPath];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *normalizedValue = [[(NSString *)value ocb_trimmedString] lowercaseString];
        if ([normalizedValue isEqualToString:@"true"] || [normalizedValue isEqualToString:@"yes"]) {
            return YES;
        }
        if ([normalizedValue isEqualToString:@"false"] || [normalizedValue isEqualToString:@"no"]) {
            return NO;
        }
        return [normalizedValue boolValue];
    }

    return defaultValue;
}

- (NSInteger)ocb_integerForKey:(id)key defaultValue:(NSInteger)defaultValue
{
    id value = self[key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }

    return defaultValue;
}

- (NSInteger)ocb_integerForKeyPath:(nullable NSString *)keyPath defaultValue:(NSInteger)defaultValue
{
    id value = [self ocb_objectForKeyPath:keyPath];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }

    return defaultValue;
}

- (double)ocb_doubleForKey:(id)key defaultValue:(double)defaultValue
{
    id value = self[key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }

    return defaultValue;
}

- (double)ocb_doubleForKeyPath:(nullable NSString *)keyPath defaultValue:(double)defaultValue
{
    id value = [self ocb_objectForKeyPath:keyPath];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }

    return defaultValue;
}

- (nullable NSDictionary *)ocb_dictionaryForKey:(id)key
{
    id value = self[key];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

- (nullable NSDictionary *)ocb_dictionaryForKeyPath:(nullable NSString *)keyPath
{
    id value = [self ocb_objectForKeyPath:keyPath];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

- (nullable NSArray *)ocb_arrayForKey:(id)key
{
    id value = self[key];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

- (nullable NSArray *)ocb_arrayForKeyPath:(nullable NSString *)keyPath
{
    id value = [self ocb_objectForKeyPath:keyPath];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

@end
