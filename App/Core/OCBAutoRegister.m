#import "OCBAutoRegister.h"

static NSMutableArray<Class> *OCBRegisteredModuleClassesStorage(void)
{
    static NSMutableArray<Class> *moduleClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        moduleClasses = [[NSMutableArray alloc] init];
    });
    return moduleClasses;
}

static NSMutableDictionary<NSString *, Class> *OCBRegisteredServiceClassesStorage(void)
{
    static NSMutableDictionary<NSString *, Class> *serviceClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceClasses = [[NSMutableDictionary alloc] init];
    });
    return serviceClasses;
}

void OCBRegisterModuleClass(Class moduleClass)
{
    if (moduleClass == Nil) {
        return;
    }

    NSMutableArray<Class> *moduleClasses = OCBRegisteredModuleClassesStorage();
    @synchronized (moduleClasses) {
        if ([moduleClasses containsObject:moduleClass]) {
            return;
        }

        [moduleClasses addObject:moduleClass];
    }
}

NSArray<Class> *OCBAllRegisteredModuleClasses(void)
{
    NSMutableArray<Class> *moduleClasses = OCBRegisteredModuleClassesStorage();
    @synchronized (moduleClasses) {
        NSArray<Class> *snapshot = [moduleClasses copy];
        return [snapshot sortedArrayUsingComparator:^NSComparisonResult(Class lhs, Class rhs) {
            return [NSStringFromClass(lhs) compare:NSStringFromClass(rhs)];
        }];
    }
}

void OCBRegisterServiceClass(Protocol *serviceProtocol, Class serviceClass)
{
    if (serviceProtocol == nil || serviceClass == Nil) {
        return;
    }

    NSMutableDictionary<NSString *, Class> *serviceClasses = OCBRegisteredServiceClassesStorage();
    @synchronized (serviceClasses) {
        serviceClasses[NSStringFromProtocol(serviceProtocol)] = serviceClass;
    }
}

NSDictionary<NSString *, Class> *OCBAllRegisteredServiceClasses(void)
{
    NSMutableDictionary<NSString *, Class> *serviceClasses = OCBRegisteredServiceClassesStorage();
    @synchronized (serviceClasses) {
        return [serviceClasses copy];
    }
}
