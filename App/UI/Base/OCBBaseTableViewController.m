#import "OCBBaseTableViewController.h"

#import "OCBThemeManager.h"

@interface OCBBaseTableViewController ()

@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite, nullable) UIRefreshControl *refreshControl;

@end

@implementation OCBBaseTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _tableViewStyle = style;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:self.tableViewStyle];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [OCBThemeManager sharedManager].backgroundColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0.0;
    }

    [self.contentView addSubview:_tableView];
    [self updateRefreshControlIfNeeded];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const OCBBaseTablePlaceholderReuseIdentifier = @"OCBBaseTablePlaceholderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OCBBaseTablePlaceholderReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OCBBaseTablePlaceholderReuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    }

    cell.textLabel.text = @"Override tableView:numberOfRowsInSection: and cellForRowAtIndexPath:.";
    return cell;
}

- (void)setPullToRefreshEnabled:(BOOL)pullToRefreshEnabled
{
    if (_pullToRefreshEnabled == pullToRefreshEnabled) {
        return;
    }

    _pullToRefreshEnabled = pullToRefreshEnabled;
    if (self.isViewLoaded) {
        [self updateRefreshControlIfNeeded];
    }
}

- (void)beginRefreshing
{
    if (!self.isPullToRefreshEnabled) {
        self.pullToRefreshEnabled = YES;
    }

    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        self.tableView.contentOffset = CGPointMake(0.0, -CGRectGetHeight(self.refreshControl.frame));
    }
}

- (void)endRefreshing
{
    [self.refreshControl endRefreshing];
}

- (void)handlePullToRefresh
{
    [self endRefreshing];
}

- (void)updateRefreshControlIfNeeded
{
    if (!self.isPullToRefreshEnabled) {
        [self.refreshControl removeTarget:self action:@selector(handleRefreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = nil;
        self.tableView.refreshControl = nil;
        return;
    }

    if (self.refreshControl == nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(handleRefreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }

    self.tableView.refreshControl = self.refreshControl;
}

- (void)handleRefreshControlValueChanged
{
    [self handlePullToRefresh];
}

@end
