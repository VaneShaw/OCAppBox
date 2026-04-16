#import "OCBBaseCollectionViewController.h"

#import "OCBThemeManager.h"

@interface OCBBaseCollectionViewController ()

@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) UICollectionViewLayout *collectionViewLayout;
@property (nonatomic, strong, readwrite, nullable) UIRefreshControl *refreshControl;

@end

@implementation OCBBaseCollectionViewController

static UICollectionViewFlowLayout *OCBDefaultCollectionViewLayout(void)
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 12.0;
    layout.minimumInteritemSpacing = 12.0;
    layout.sectionInset = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0);
    return layout;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithCollectionViewLayout:OCBDefaultCollectionViewLayout()];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithCollectionViewLayout:OCBDefaultCollectionViewLayout()];
}

- (instancetype)init
{
    return [self initWithCollectionViewLayout:OCBDefaultCollectionViewLayout()];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _collectionViewLayout = layout;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor = [OCBThemeManager sharedManager].backgroundColor;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;

    [self.view insertSubview:_collectionView atIndex:0];
    [self updateRefreshControlIfNeeded];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException
                format:@"%@ must override collectionView:cellForItemAtIndexPath: after registering cells.",
                       NSStringFromClass([self class])];
    return [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
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
        self.collectionView.contentOffset = CGPointMake(0.0, -CGRectGetHeight(self.refreshControl.frame));
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
        self.collectionView.refreshControl = nil;
        return;
    }

    if (self.refreshControl == nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(handleRefreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }

    self.collectionView.refreshControl = self.refreshControl;
}

- (void)handleRefreshControlValueChanged
{
    [self handlePullToRefresh];
}

@end
