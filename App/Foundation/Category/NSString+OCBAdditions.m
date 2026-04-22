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

- (NSString *)ocb_urlEncodedString
{
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@":#[]@!$&'()*+,;="] invertedSet];
    NSString *encodedString = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    return encodedString ?: self;
}

- (nullable NSDictionary *)ocb_JSONDictionaryObject
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length == 0) {
        return nil;
    }

    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error != nil || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return object;
}

@end
