#import <OCAppBox/UI/Base/OCBBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBBaseCollectionViewController : OCBBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, readonly) UICollectionViewLayout *collectionViewLayout;
@property (nonatomic, strong, readonly, nullable) UIRefreshControl *refreshControl;
@property (nonatomic, assign, getter=isPullToRefreshEnabled) BOOL pullToRefreshEnabled;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

- (void)handlePullToRefresh;
- (void)beginRefreshing;
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
