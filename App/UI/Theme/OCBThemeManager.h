#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCBThemeProviding <NSObject>

@property (nonatomic, strong, readonly) UIColor *backgroundColor;
@property (nonatomic, strong, readonly) UIColor *tintColor;
@property (nonatomic, strong, readonly) UIColor *primaryTextColor;
@property (nonatomic, strong, readonly) UIColor *secondaryTextColor;

@end

@interface OCBThemeManager : NSObject <OCBThemeProviding>

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *primaryTextColor;
@property (nonatomic, strong) UIColor *secondaryTextColor;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
