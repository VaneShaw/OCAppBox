#import <XCTest/XCTest.h>
#import <OCAppBox/OCAppBox.h>

@interface OCBTableFixtureViewController : OCBBaseTableViewController
@end

@implementation OCBTableFixtureViewController

- (instancetype)init
{
    return [super initWithStyle:UITableViewStyleInsetGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pullToRefreshEnabled = YES;
}

@end

@interface OCBCollectionFixtureViewController : OCBBaseCollectionViewController
@end

@implementation OCBCollectionFixtureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pullToRefreshEnabled = YES;
}

@end

@interface OCBStatusFixtureViewController : OCBBaseViewController
@end

@implementation OCBStatusFixtureViewController
@end

@interface OCBUIBaseControllerTests : XCTestCase
@end

@implementation OCBUIBaseControllerTests

- (void)testBaseTableViewControllerCreatesTableViewAndRefreshControl
{
    OCBTableFixtureViewController *viewController = [[OCBTableFixtureViewController alloc] init];
    [viewController loadViewIfNeeded];

    XCTAssertNotNil(viewController.tableView);
    XCTAssertTrue(viewController.tableView.delegate == viewController);
    XCTAssertTrue(viewController.tableView.dataSource == viewController);
    XCTAssertTrue(viewController.isPullToRefreshEnabled);
    XCTAssertNotNil(viewController.refreshControl);

    [viewController beginRefreshing];
    [viewController endRefreshing];
    XCTAssertNotNil(viewController.refreshControl);
}

- (void)testBaseCollectionViewControllerCreatesCollectionViewAndRefreshControl
{
    OCBCollectionFixtureViewController *viewController = [[OCBCollectionFixtureViewController alloc] init];
    [viewController loadViewIfNeeded];

    XCTAssertNotNil(viewController.collectionView);
    XCTAssertTrue(viewController.collectionView.delegate == viewController);
    XCTAssertTrue(viewController.collectionView.dataSource == viewController);
    XCTAssertTrue(viewController.isPullToRefreshEnabled);
    XCTAssertNotNil(viewController.refreshControl);

    [viewController beginRefreshing];
    [viewController endRefreshing];
    XCTAssertNotNil(viewController.refreshControl);
}

- (void)testBaseViewControllerErrorStateSupportsRetryAction
{
    OCBStatusFixtureViewController *viewController = [[OCBStatusFixtureViewController alloc] init];
    [viewController loadViewIfNeeded];

    __block NSInteger retryCallCount = 0;
    [viewController showErrorWithTitle:@"Network Error"
                                detail:@"Tap retry to request the latest payload."
                            retryTitle:@"Retry Now"
                          retryHandler:^{
        retryCallCount += 1;
    }];

    XCTAssertFalse(viewController.emptyStateView.hidden);

    UIButton *retryButton = nil;
    for (UIView *subview in viewController.emptyStateView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            retryButton = (UIButton *)subview;
            break;
        }
    }

    XCTAssertNotNil(retryButton);
    XCTAssertFalse(retryButton.hidden);
    [retryButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    XCTAssertEqual(retryCallCount, 1);
}

@end
