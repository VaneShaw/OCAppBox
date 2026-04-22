#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (OCBAdditions)

- (nullable id)ocb_objectForKeyPath:(nullable NSString *)keyPath;
- (nullable NSString *)ocb_stringForKey:(id)key defaultValue:(nullable NSString *)defaultValue;
- (nullable NSString *)ocb_stringForKeyPath:(nullable NSString *)keyPath defaultValue:(nullable NSString *)defaultValue;
- (BOOL)ocb_boolForKey:(id)key defaultValue:(BOOL)defaultValue;
- (BOOL)ocb_boolForKeyPath:(nullable NSString *)keyPath defaultValue:(BOOL)defaultValue;
- (NSInteger)ocb_integerForKey:(id)key defaultValue:(NSInteger)defaultValue;
- (NSInteger)ocb_integerForKeyPath:(nullable NSString *)keyPath defaultValue:(NSInteger)defaultValue;
- (double)ocb_doubleForKey:(id)key defaultValue:(double)defaultValue;
- (double)ocb_doubleForKeyPath:(nullable NSString *)keyPath defaultValue:(double)defaultValue;
- (nullable NSDictionary *)ocb_dictionaryForKey:(id)key;
- (nullable NSDictionary *)ocb_dictionaryForKeyPath:(nullable NSString *)keyPath;
- (nullable NSArray *)ocb_arrayForKey:(id)key;
- (nullable NSArray *)ocb_arrayForKeyPath:(nullable NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
