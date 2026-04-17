#import "OCBServiceRegistry.h"

@interface OCBServiceRegistry ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *serviceInstances;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *serviceClasses;

@end

@implementation OCBServiceRegistry

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serviceInstances = [[NSMutableDictionary alloc] init];
        _serviceClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerService:(id)service forProtocol:(Protocol *)serviceProtocol
{
    if (!service || !serviceProtocol) {
        return;
    }

    @synchronized (self) {
        self.serviceInstances[NSStringFromProtocol(serviceProtocol)] = service;
    }
}

- (void)registerServiceClass:(Class)serviceClass forProtocol:(Protocol *)serviceProtocol
{
    if (!serviceClass || !serviceProtocol) {
        return;
    }

    @synchronized (self) {
        self.serviceClasses[NSStringFromProtocol(serviceProtocol)] = serviceClass;
    }
}

- (nullable id)serviceForProtocol:(Protocol *)serviceProtocol
{
    if (!serviceProtocol) {
        return nil;
    }

    NSString *key = NSStringFromProtocol(serviceProtocol);

    @synchronized (self) {
        id service = self.serviceInstances[key];
        if (service) {
            return service;
        }

        Class serviceClass = self.serviceClasses[key];
        if (!serviceClass) {
            return nil;
        }

        id createdService = [[serviceClass alloc] init];
        if (createdService) {
            self.serviceInstances[key] = createdService;
        }
        return createdService;
    }
}

- (BOOL)containsServiceForProtocol:(Protocol *)serviceProtocol
{
    if (!serviceProtocol) {
        return NO;
    }

    NSString *key = NSStringFromProtocol(serviceProtocol);

    @synchronized (self) {
        return (self.serviceInstances[key] != nil || self.serviceClasses[key] != nil);
    }
}

- (NSArray<NSString *> *)allRegisteredProtocolNames
{
    @synchronized (self) {
        NSMutableSet<NSString *> *protocolNames = [[NSMutableSet alloc] init];
        [protocolNames addObjectsFromArray:self.serviceClasses.allKeys];
        [protocolNames addObjectsFromArray:self.serviceInstances.allKeys];
        return [[protocolNames allObjects] sortedArrayUsingSelector:@selector(compare:)];
    }
}

- (NSArray<NSString *> *)allInstantiatedProtocolNames
{
    @synchronized (self) {
        return [[self.serviceInstances allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }
}

@end
