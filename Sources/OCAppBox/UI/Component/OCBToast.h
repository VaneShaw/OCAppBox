#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBToast : NSObject

+ (void)showText:(NSString *)text;
+ (void)showText:(NSString *)text inView:(UIView *)view;
+ (void)showText:(NSString *)text inView:(UIView *)view duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
