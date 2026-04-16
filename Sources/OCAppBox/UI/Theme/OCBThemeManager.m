#import "OCBThemeManager.h"

#import "UIColor+OCBAdditions.h"

@implementation OCBThemeManager

+ (instancetype)sharedManager
{
    static OCBThemeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[OCBThemeManager alloc] init];
        manager.backgroundColor = [UIColor ocb_colorWithHexValue:0xF5F7FC];
        manager.tintColor = [UIColor ocb_colorWithHexValue:0x1452AB];
        manager.primaryTextColor = [UIColor ocb_colorWithHexValue:0x171F2E];
        manager.secondaryTextColor = [UIColor ocb_colorWithHexValue:0x5C6B82];
    });
    return manager;
}

@end
