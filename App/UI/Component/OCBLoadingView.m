#import "OCBLoadingView.h"

@interface OCBLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation OCBLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.08];

        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _indicatorView.color = [UIColor darkGrayColor];

        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor darkGrayColor];
        _textLabel.text = @"Loading";

        [self addSubview:_indicatorView];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    self.textLabel.text = _text.length > 0 ? _text : @"Loading";
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    self.indicatorView.frame = CGRectMake((width - 40.0) * 0.5, (height - 66.0) * 0.5, 40.0, 40.0);
    self.textLabel.frame = CGRectMake(24.0, CGRectGetMaxY(self.indicatorView.frame) + 12.0, width - 48.0, 20.0);
}

- (void)startAnimating
{
    self.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)stopAnimating
{
    self.hidden = YES;
    [self.indicatorView stopAnimating];
}

@end
