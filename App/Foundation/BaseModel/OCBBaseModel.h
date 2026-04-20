#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 轻量模型基类：统一 `id` 字段与 `NSSecureCoding`，便于与磁盘缓存等能力配合；子类可覆写 `initWithDictionary:` / `toDictionary`。
@interface OCBBaseModel : NSObject <NSSecureCoding>

@property (nonatomic, copy, nullable) NSString *modelIdentifier;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary NS_DESIGNATED_INITIALIZER;

- (NSDictionary<NSString *, id> *)toDictionary;

@end

NS_ASSUME_NONNULL_END
