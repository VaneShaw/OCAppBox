#import "OCBAppMetadata.h"

#import "NSDictionary+OCBAdditions.h"
#import "NSString+OCBAdditions.h"

@implementation OCBAppMetadata

+ (NSDictionary *)mainBundleInfoDictionary
{
    return [[NSBundle mainBundle] infoDictionary] ?: @{};
}

+ (NSString *)displayName
{
    NSDictionary *infoDictionary = [self mainBundleInfoDictionary];
    NSString *displayName = [infoDictionary ocb_stringForKey:@"CFBundleDisplayName" defaultValue:nil];
    if ([displayName ocb_isNotBlank]) {
        return displayName;
    }

    NSString *bundleName = [infoDictionary ocb_stringForKey:@"CFBundleName" defaultValue:@"App"];
    return [bundleName ocb_isNotBlank] ? bundleName : @"App";
}

+ (NSString *)bundleIdentifier
{
    return [NSString ocb_stringWithObject:[NSBundle mainBundle].bundleIdentifier defaultValue:@"-"];
}

+ (NSString *)versionString
{
    return [[self mainBundleInfoDictionary] ocb_stringForKey:@"CFBundleShortVersionString" defaultValue:@"1.0.0"];
}

+ (NSString *)buildString
{
    return [[self mainBundleInfoDictionary] ocb_stringForKey:@"CFBundleVersion" defaultValue:@"1"];
}

+ (NSString *)versionDisplayString
{
    return [NSString stringWithFormat:@"%@ (%@)", [self versionString], [self buildString]];
}

@end
