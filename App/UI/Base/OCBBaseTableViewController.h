#import <UI/Base/OCBBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBBaseTableViewController : OCBBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly, nullable) UIRefreshControl *refreshControl;
@property (nonatomic, assign, getter=isPullToRefreshEnabled) BOOL pullToRefreshEnabled;

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

- (void)handlePullToRefresh;
- (void)beginRefreshing;
- (void)endRefreshing;

@end

NS_ASSUME_NONNULL_END
