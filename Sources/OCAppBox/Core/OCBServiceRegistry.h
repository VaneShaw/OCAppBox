#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBServiceRegistry : NSObject

- (void)registerService:(id)service forProtocol:(Protocol *)serviceProtocol;
- (void)registerServiceClass:(Class)serviceClass forProtocol:(Protocol *)serviceProtocol;
- (nullable id)serviceForProtocol:(Protocol *)serviceProtocol;
- (BOOL)containsServiceForProtocol:(Protocol *)serviceProtocol;
- (NSArray<NSString *> *)allRegisteredProtocolNames;
- (NSArray<NSString *> *)allInstantiatedProtocolNames;

@end

NS_ASSUME_NONNULL_END
