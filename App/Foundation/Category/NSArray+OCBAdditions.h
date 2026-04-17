#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (OCBAdditions)

- (nullable id)ocb_objectAtIndexSafely:(NSUInteger)index;
- (nullable NSString *)ocb_stringAtIndex:(NSUInteger)index defaultValue:(nullable NSString *)defaultValue;
- (nullable NSDictionary *)ocb_dictionaryAtIndex:(NSUInteger)index;
- (nullable NSArray *)ocb_arrayAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
