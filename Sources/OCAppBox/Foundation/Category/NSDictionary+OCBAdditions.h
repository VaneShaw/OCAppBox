#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (OCBAdditions)

- (nullable NSString *)ocb_stringForKey:(id)key defaultValue:(nullable NSString *)defaultValue;
- (BOOL)ocb_boolForKey:(id)key defaultValue:(BOOL)defaultValue;
- (NSInteger)ocb_integerForKey:(id)key defaultValue:(NSInteger)defaultValue;
- (nullable NSDictionary *)ocb_dictionaryForKey:(id)key;
- (nullable NSArray *)ocb_arrayForKey:(id)key;

@end

NS_ASSUME_NONNULL_END
