#import "NSArray+OCBAdditions.h"

#import "NSString+OCBAdditions.h"

@implementation NSArray (OCBAdditions)

- (nullable id)ocb_objectAtIndexSafely:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    }

    id value = self[index];
    return value == [NSNull null] ? nil : value;
}

- (nullable NSString *)ocb_stringAtIndex:(NSUInteger)index defaultValue:(nullable NSString *)defaultValue
{
    return [NSString ocb_stringWithObject:[self ocb_objectAtIndexSafely:index] defaultValue:defaultValue];
}

- (nullable NSDictionary *)ocb_dictionaryAtIndex:(NSUInteger)index
{
    id value = [self ocb_objectAtIndexSafely:index];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

- (nullable NSArray *)ocb_arrayAtIndex:(NSUInteger)index
{
    id value = [self ocb_objectAtIndexSafely:index];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

@end
