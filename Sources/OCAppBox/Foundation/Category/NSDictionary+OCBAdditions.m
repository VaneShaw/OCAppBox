#import "NSDictionary+OCBAdditions.h"

#import "NSString+OCBAdditions.h"

@implementation NSDictionary (OCBAdditions)

- (nullable NSString *)ocb_stringForKey:(id)key defaultValue:(nullable NSString *)defaultValue
{
    id value = self[key];
    if (value == nil || value == [NSNull null]) {
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

- (NSInteger)ocb_integerForKey:(id)key defaultValue:(NSInteger)defaultValue
{
    id value = self[key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }

    return defaultValue;
}

- (nullable NSDictionary *)ocb_dictionaryForKey:(id)key
{
    id value = self[key];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

- (nullable NSArray *)ocb_arrayForKey:(id)key
{
    id value = self[key];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

@end
