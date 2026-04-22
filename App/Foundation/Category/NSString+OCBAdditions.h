#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (OCBAdditions)

+ (NSString *)ocb_stringWithObject:(nullable id)object defaultValue:(nullable NSString *)defaultValue;
- (NSString *)ocb_trimmedString;
- (BOOL)ocb_isNotBlank;
- (NSString *)ocb_urlEncodedString;
- (nullable NSDictionary *)ocb_JSONDictionaryObject;

@end

NS_ASSUME_NONNULL_END
