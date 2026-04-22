#import "OCBEmptyStateView.h"

#import "OCBThemeManager.h"

@interface OCBEmptyStateView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, copy, nullable) OCBEmptyStateActionHandler actionHandler;

@end

@implementation OCBEmptyStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [OCBThemeManager sharedManager].backgroundColor;

        [self addSubview:self.titleLabel];
        [self addSubview:self.detailLabel];
        [self addSubview:self.actionButton];
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title detail:(nullable NSString *)detail
{
    [self updateWithTitle:title detail:detail actionTitle:nil actionHandler:nil];
}

- (void)updateWithTitle:(NSString *)title
                 detail:(nullable NSString *)detail
            actionTitle:(nullable NSString *)actionTitle
          actionHandler:(nullable OCBEmptyStateActionHandler)actionHandler
{
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    self.actionHandler = actionHandler;
    self.actionButton.hidden = actionTitle.length == 0;
    if (actionTitle.length > 0) {
        [self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
    } else {
        [self.actionButton setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat top = (CGRectGetHeight(self.bounds) - 170.0) * 0.5;
    self.titleLabel.frame = CGRectMake(24.0, top, width - 48.0, 30.0);
    self.detailLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.titleLabel.frame) + 12.0, width - 48.0, 78.0);
    self.actionButton.frame = CGRectMake(40.0, CGRectGetMaxY(self.detailLabel.frame) + 18.0, width - 80.0, 48.0);
}

- (void)handleActionButtonTap
{
    if (self.actionHandler != nil) {
        self.actionHandler();
    }
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [OCBThemeManager sharedManager].primaryTextColor;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = [UIFont systemFontOfSize:15.0];
        _detailLabel.textColor = [OCBThemeManager sharedManager].secondaryTextColor;
    }
    return _detailLabel;
}

- (UIButton *)actionButton
{
    if (_actionButton == nil) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _actionButton.hidden = YES;
        _actionButton.backgroundColor = [OCBThemeManager sharedManager].tintColor;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        _actionButton.layer.cornerRadius = 12.0;
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(handleActionButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

@end
