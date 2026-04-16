#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class OCBAppContext;

@protocol OCBAppContextServiceFactory <NSObject>

+ (id)serviceWithAppContext:(OCBAppContext *)appContext;

@end

FOUNDATION_EXPORT void OCBRegisterModuleClass(Class moduleClass);
FOUNDATION_EXPORT NSArray<Class> *OCBAllRegisteredModuleClasses(void);

FOUNDATION_EXPORT void OCBRegisterServiceClass(Protocol *serviceProtocol, Class serviceClass);
FOUNDATION_EXPORT NSDictionary<NSString *, Class> *OCBAllRegisteredServiceClasses(void);

#define OCB_EXPORT_MODULE(MODULE_CLASS) \
    __attribute__((constructor)) static void ocb_export_module_##MODULE_CLASS(void) { \
        OCBRegisterModuleClass([MODULE_CLASS class]); \
    }

#define OCB_EXPORT_SERVICE(SERVICE_PROTOCOL, SERVICE_CLASS) \
    __attribute__((constructor)) static void ocb_export_service_##SERVICE_CLASS(void) { \
        OCBRegisterServiceClass(@protocol(SERVICE_PROTOCOL), [SERVICE_CLASS class]); \
    }

NS_ASSUME_NONNULL_END
