#import "OCBKeychainStore.h"
#import <Security/Security.h>

@interface OCBKeychainStore ()

@property (nonatomic, copy, readonly) NSString *serviceIdentifier;

@end

@implementation OCBKeychainStore

- (instancetype)initWithServiceIdentifier:(NSString *)serviceIdentifier
{
    self = [super init];
    if (self) {
        _serviceIdentifier = [serviceIdentifier copy];
    }
    return self;
}

- (instancetype)init
{
    NSString *sid = [[NSBundle mainBundle] bundleIdentifier];
    if (sid.length == 0) {
        sid = @"com.ocappbox.OCBKeychain";
    }
    return [self initWithServiceIdentifier:sid];
}

static NSError *OCBKeychainNSError(OSStatus status)
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Keychain OSStatus %d", (int)status]};
    return [NSError errorWithDomain:@"OCBKeychainStore" code:(NSInteger)status userInfo:userInfo];
}

- (NSMutableDictionary<NSString *, id> *)queryForAccount:(NSString *)account returnData:(BOOL)returnData
{
    NSMutableDictionary<NSString *, id> *query = [@{
        (__bridge NSString *)kSecClass: (__bridge NSString *)kSecClassGenericPassword,
        (__bridge NSString *)kSecAttrService: self.serviceIdentifier,
        (__bridge NSString *)kSecAttrAccount: account,
    } mutableCopy];
    if (returnData) {
        query[(__bridge NSString *)kSecReturnData] = @YES;
        query[(__bridge NSString *)kSecMatchLimit] = (__bridge NSString *)kSecMatchLimitOne;
    }
    return query;
}

- (BOOL)removeStringForAccount:(NSString *)account error:(NSError *__autoreleasing _Nullable *_Nullable)error
{
    if (account.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"OCBKeychainStore" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"account 不能为空"}];
        }
        return NO;
    }
    NSDictionary *query = [self queryForAccount:account returnData:NO];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess || status == errSecItemNotFound) {
        return YES;
    }
    if (error != NULL) {
        *error = OCBKeychainNSError(status);
    }
    return NO;
}

- (BOOL)setString:(NSString *)value forAccount:(NSString *)account error:(NSError *__autoreleasing _Nullable *_Nullable)error
{
    if (account.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"OCBKeychainStore" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"account 不能为空"}];
        }
        return NO;
    }
    if (![self removeStringForAccount:account error:error]) {
        return NO;
    }
    if (value.length == 0) {
        return YES;
    }
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"OCBKeychainStore" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"字符串编码失败"}];
        }
        return NO;
    }
    NSMutableDictionary *attributes = [self queryForAccount:account returnData:NO];
    attributes[(__bridge NSString *)kSecValueData] = data;

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
    if (status == errSecSuccess) {
        return YES;
    }
    if (error != NULL) {
        *error = OCBKeychainNSError(status);
    }
    return NO;
}

- (nullable NSString *)stringForAccount:(NSString *)account error:(NSError *__autoreleasing _Nullable *_Nullable)error
{
    if (account.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"OCBKeychainStore" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"account 不能为空"}];
        }
        return nil;
    }
    NSDictionary *query = [self queryForAccount:account returnData:YES];
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecItemNotFound) {
        return nil;
    }
    if (status != errSecSuccess) {
        if (error != NULL) {
            *error = OCBKeychainNSError(status);
        }
        return nil;
    }
    NSData *data = (__bridge_transfer NSData *)result;
    if (data.length == 0) {
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
