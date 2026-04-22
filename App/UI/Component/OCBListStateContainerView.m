#import "OCBListStateContainerView.h"

#import <Masonry/Masonry.h>

#import "OCBEmptyStateView.h"
#import "OCBFoundationMacros.h"
#import "OCBLoadingView.h"

@interface OCBListStateContainerView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) OCBLoadingView *loadingView;
@property (nonatomic, strong) OCBEmptyStateView *emptyStateView;
@property (nonatomic, assign, readwrite) OCBListState state;

@end

@implementation OCBListStateContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _state = OCBListStateContent;
        [self setupSubviews];
        [self showContent];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.contentView];
    [self addSubview:self.loadingView];
    [self addSubview:self.emptyStateView];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.emptyStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)showContent
{
    self.state = OCBListStateContent;
    [self.loadingView stopAnimating];
    self.emptyStateView.hidden = YES;
    self.contentView.hidden = NO;
}

- (void)showLoadingWithText:(nullable NSString *)text
{
    self.state = OCBListStateLoading;
    self.contentView.hidden = YES;
    self.emptyStateView.hidden = YES;
    self.loadingView.text = text.length > 0 ? text : OCBLocalizedString(@"ocb.loading");
    [self.loadingView startAnimating];
}

- (void)showEmptyWithTitle:(NSString *)title detail:(nullable NSString *)detail
{
    self.state = OCBListStateEmpty;
    [self.loadingView stopAnimating];
    self.contentView.hidden = YES;
    self.emptyStateView.hidden = NO;
    [self.emptyStateView updateWithTitle:title
                                  detail:detail
                             actionTitle:nil
                           actionHandler:nil];
}

- (void)showErrorWithTitle:(NSString *)title detail:(nullable NSString *)detail
{
    self.state = OCBListStateError;
    [self.loadingView stopAnimating];
    self.contentView.hidden = YES;
    self.emptyStateView.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [self.emptyStateView updateWithTitle:title
                                  detail:detail
                             actionTitle:OCBLocalizedString(@"ocb.retry")
                           actionHandler:^{
        if (weakSelf.retryHandler != nil) {
            weakSelf.retryHandler();
        }
    }];
}

- (UIView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (OCBLoadingView *)loadingView
{
    if (_loadingView == nil) {
        _loadingView = [[OCBLoadingView alloc] initWithFrame:CGRectZero];
    }
    return _loadingView;
}

- (OCBEmptyStateView *)emptyStateView
{
    if (_emptyStateView == nil) {
        _emptyStateView = [[OCBEmptyStateView alloc] initWithFrame:CGRectZero];
    }
    return _emptyStateView;
}

@end
