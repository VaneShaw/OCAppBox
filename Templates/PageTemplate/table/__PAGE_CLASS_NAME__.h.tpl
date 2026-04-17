#import <UI/Base/OCBBaseTableViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;

@interface __PAGE_CLASS_NAME__ : OCBBaseTableViewController

- (instancetype)initWithAppContext:(OCBAppContext *)appContext NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
