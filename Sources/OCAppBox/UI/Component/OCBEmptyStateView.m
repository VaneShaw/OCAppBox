#import "OCBEmptyStateView.h"

@interface OCBEmptyStateView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation OCBEmptyStateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightSemibold];
        _titleLabel.textColor = [UIColor darkTextColor];

        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
        _detailLabel.font = [UIFont systemFontOfSize:15.0];
        _detailLabel.textColor = [UIColor grayColor];

        [self addSubview:_titleLabel];
        [self addSubview:_detailLabel];
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title detail:(nullable NSString *)detail
{
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat top = (CGRectGetHeight(self.bounds) - 120.0) * 0.5;
    self.titleLabel.frame = CGRectMake(24.0, top, width - 48.0, 30.0);
    self.detailLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.titleLabel.frame) + 12.0, width - 48.0, 78.0);
}

@end
