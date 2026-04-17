#import "NSString+OCBAdditions.h"

@implementation NSString (OCBAdditions)

+ (NSString *)ocb_stringWithObject:(nullable id)object defaultValue:(nullable NSString *)defaultValue
{
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    }

    if ([object respondsToSelector:@selector(stringValue)]) {
        NSString *stringValue = [object stringValue];
        if ([stringValue isKindOfClass:[NSString class]]) {
            return stringValue;
        }
    }

    return defaultValue ?: @"";
}

- (NSString *)ocb_trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)ocb_isNotBlank
{
    return self.ocb_trimmedString.length > 0;
}

@end
