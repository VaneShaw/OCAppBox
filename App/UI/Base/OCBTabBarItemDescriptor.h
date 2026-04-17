#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBTabBarItemDescriptor : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *routePath;
@property (nonatomic, copy, readonly) NSDictionary *routeParams;
@property (nonatomic, copy, nullable, readonly) NSString *systemImageName;
@property (nonatomic, copy, nullable, readonly) NSString *selectedSystemImageName;

+ (instancetype)itemWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
              systemImageName:(nullable NSString *)systemImageName;
+ (instancetype)itemWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
              systemImageName:(nullable NSString *)systemImageName
      selectedSystemImageName:(nullable NSString *)selectedSystemImageName;
+ (instancetype)itemWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
                  routeParams:(nullable NSDictionary *)routeParams
              systemImageName:(nullable NSString *)systemImageName
      selectedSystemImageName:(nullable NSString *)selectedSystemImageName;

- (instancetype)initWithTitle:(NSString *)title
                    routePath:(NSString *)routePath
                  routeParams:(nullable NSDictionary *)routeParams
              systemImageName:(nullable NSString *)systemImageName
      selectedSystemImageName:(nullable NSString *)selectedSystemImageName NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
