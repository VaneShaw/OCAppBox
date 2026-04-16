#import "OCBThemeManager.h"

@implementation OCBThemeManager

+ (instancetype)sharedManager
{
    static OCBThemeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[OCBThemeManager alloc] init];
        manager.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.99 alpha:1.0];
        manager.tintColor = [UIColor colorWithRed:0.08 green:0.32 blue:0.67 alpha:1.0];
        manager.primaryTextColor = [UIColor colorWithRed:0.09 green:0.12 blue:0.18 alpha:1.0];
        manager.secondaryTextColor = [UIColor colorWithRed:0.36 green:0.42 blue:0.51 alpha:1.0];
    });
    return manager;
}

@end
