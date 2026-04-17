#import "OCBCacheCenter.h"

@interface OCBCacheCenter ()

@property (nonatomic, strong) NSCache<NSString *, id> *memoryCache;
@property (nonatomic, copy, readwrite) NSString *diskCacheDirectory;

@end

@implementation OCBCacheCenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _memoryCache = [[NSCache alloc] init];
        _diskCacheDirectory = [self buildDiskCacheDirectory];
        [[NSFileManager defaultManager] createDirectoryAtPath:_diskCacheDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return self;
}

- (void)setMemoryObject:(nullable id)object forKey:(NSString *)key
{
    if (key.length == 0) {
        return;
    }

    if (object == nil) {
        [self.memoryCache removeObjectForKey:key];
        return;
    }

    [self.memoryCache setObject:object forKey:key];
}

- (nullable id)memoryObjectForKey:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }

    return [self.memoryCache objectForKey:key];
}

- (void)setDiskObject:(nullable id<NSSecureCoding>)object forKey:(NSString *)key
{
    if (key.length == 0) {
        return;
    }

    NSString *filePath = [self filePathForKey:key];
    if (object == nil) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        return;
    }

    NSError *archiveError = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object
                                         requiringSecureCoding:NO
                                                         error:&archiveError];
    if (data == nil || archiveError != nil) {
        return;
    }

    [data writeToFile:filePath atomically:YES];
}

- (nullable id)diskObjectForKey:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }

    NSData *data = [NSData dataWithContentsOfFile:[self filePathForKey:key]];
    if (data == nil) {
        return nil;
    }

    NSError *unarchiveError = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&unarchiveError];
    if (unarchiver == nil || unarchiveError != nil) {
        return nil;
    }

    unarchiver.requiresSecureCoding = NO;
    id object = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [unarchiver finishDecoding];
    if (unarchiveError != nil) {
        return nil;
    }

    return object;
}

- (void)removeObjectForKey:(NSString *)key
{
    if (key.length == 0) {
        return;
    }

    [self.memoryCache removeObjectForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:[self filePathForKey:key] error:nil];
}

- (NSString *)buildDiskCacheDirectory
{
    NSString *cacheRoot = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return [cacheRoot stringByAppendingPathComponent:@"OCAppBox/Storage"];
}

- (NSString *)filePathForKey:(NSString *)key
{
    NSString *safeKey = [[key componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/:"]] componentsJoinedByString:@"_"];
    return [self.diskCacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.archive", safeKey]];
}

@end
