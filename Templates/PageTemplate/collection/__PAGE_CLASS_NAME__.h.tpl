#import <UI/Base/OCBBaseCollectionViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;

@interface __PAGE_CLASS_NAME__ : OCBBaseCollectionViewController

- (instancetype)initWithAppContext:(OCBAppContext *)appContext NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
