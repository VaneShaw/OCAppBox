#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCBStorageProviding <NSObject>

- (void)setMemoryObject:(nullable id)object forKey:(NSString *)key;
- (nullable id)memoryObjectForKey:(NSString *)key;
- (void)setDiskObject:(nullable id<NSSecureCoding>)object forKey:(NSString *)key;
- (nullable id)diskObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@end

@interface OCBCacheCenter : NSObject <OCBStorageProviding>

@property (nonatomic, copy, readonly) NSString *diskCacheDirectory;

@end

NS_ASSUME_NONNULL_END
