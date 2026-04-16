#import "__PAGE_CLASS_NAME__.h"

#import <OCAppBox/OCAppBox.h>

static NSString * const __PAGE_CLASS_NAME__CellReuseIdentifier = @"__PAGE_CLASS_NAME__Cell";

@interface __PAGE_CLASS_NAME__CardCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation __PAGE_CLASS_NAME__CardCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 18.0;
        self.contentView.layer.borderWidth = 1.0;
        self.contentView.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.06] CGColor];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;
        _titleLabel.numberOfLines = 0;

        [self.contentView addSubview:_titleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16.0],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
            [_titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16.0]
        ]];
    }
    return self;
}

@end

@interface __PAGE_CLASS_NAME__ () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, copy) NSArray<NSString *> *items;

@end

@implementation __PAGE_CLASS_NAME__

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 16.0;
    layout.minimumInteritemSpacing = 16.0;
    layout.sectionInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);

    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _appContext = appContext;
        _items = @[
            @"Card Alpha",
            @"Card Beta",
            @"Card Gamma",
            @"Card Delta"
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

    [self.collectionView registerClass:[__PAGE_CLASS_NAME__CardCell class] forCellWithReuseIdentifier:__PAGE_CLASS_NAME__CellReuseIdentifier];
    [self reloadVisibleState];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __PAGE_CLASS_NAME__CardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:__PAGE_CLASS_NAME__CellReuseIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = self.items[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentWidth = CGRectGetWidth(collectionView.bounds) - 56.0;
    CGFloat itemWidth = floor(contentWidth / 2.0);
    return CGSizeMake(MAX(itemWidth, 120.0), 120.0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showToastWithText:self.items[indexPath.item]];
}

- (void)handlePullToRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.items = [[self.items reverseObjectEnumerator] allObjects];
        [self.collectionView reloadData];
        [self endRefreshing];
        [self reloadVisibleState];
        [self showToastWithText:@"Collection refreshed."];
    });
}

- (void)reloadVisibleState
{
    if (self.items.count == 0) {
        __weak typeof(self) weakSelf = self;
        [self showEmptyWithTitle:@"No Cards Yet"
                          detail:@"This generated collection page already includes pull-to-refresh and an empty-state hook."
                     actionTitle:@"Reload"
                   actionHandler:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.items = @[@"Recovered card"];
            [strongSelf.collectionView reloadData];
            [strongSelf hideEmpty];
        }];
        return;
    }

    [self hideEmpty];
}

@end
