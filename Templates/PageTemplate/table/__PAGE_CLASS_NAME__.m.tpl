#import "__PAGE_CLASS_NAME__.h"

#import <OCAppBox.h>

@interface __PAGE_CLASS_NAME__ ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, copy) NSArray<NSString *> *items;

@end

@implementation __PAGE_CLASS_NAME__

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
{
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _appContext = appContext;
        _items = @[
            @"Primary cell",
            @"Secondary cell",
            @"More business rows"
        ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"__DISPLAY_TITLE__";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.pullToRefreshEnabled = YES;
    [self reloadVisibleState];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"__PAGE_CLASS_NAME__Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSString *title = self.items[indexPath.row];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"Generated table page. Replace sample data with your list model.";
    cell.textLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    cell.detailTextLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showToastWithText:self.items[indexPath.row]];
}

- (void)handlePullToRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.items = [[self.items reverseObjectEnumerator] allObjects];
        [self.tableView reloadData];
        [self endRefreshing];
        [self reloadVisibleState];
        [self showToastWithText:@"List refreshed."];
    });
}

- (void)reloadVisibleState
{
    if (self.items.count == 0) {
        __weak typeof(self) weakSelf = self;
        [self showEmptyWithTitle:@"No Rows Yet"
                          detail:@"This generated table page already has pull-to-refresh and empty-state hooks."
                     actionTitle:@"Reload"
                   actionHandler:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.items = @[@"Recovered row"];
            [strongSelf.tableView reloadData];
            [strongSelf hideEmpty];
        }];
        return;
    }

    [self hideEmpty];
}

@end
