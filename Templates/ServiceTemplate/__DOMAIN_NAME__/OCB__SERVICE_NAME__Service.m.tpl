#import "OCB__SERVICE_NAME__Service.h"

#import "OCBAppContext.h"
#import "OCBAutoRegister.h"
#import "OCBCacheCenter.h"
#import "OCBLogger.h"
#import "OCBServiceRegistry.h"

NSString * const OCB__SERVICE_NAME__DidChangeNotification = @"OCB__SERVICE_NAME__DidChangeNotification";

static NSString * const OCB__SERVICE_NAME__StorageKey = @"service.__SERVICE_IDENTIFIER__.state";

OCB_EXPORT_SERVICE(OCB__SERVICE_NAME__Providing, OCB__SERVICE_NAME__Service)

@interface OCB__SERVICE_NAME__Service ()

@property (nonatomic, strong) id<OCBStorageProviding> storage;
@property (nonatomic, strong) id<OCBLogging> logger;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *state;

@end

@implementation OCB__SERVICE_NAME__Service

+ (id)serviceWithAppContext:(OCBAppContext *)appContext
{
    id<OCBStorageProviding> storage = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBStorageProviding)];
    id<OCBLogging> logger = [appContext.serviceRegistry serviceForProtocol:@protocol(OCBLogging)];
    return [[self alloc] initWithStorage:storage logger:logger];
}

- (instancetype)initWithStorage:(id<OCBStorageProviding>)storage
                         logger:(id<OCBLogging>)logger
{
    self = [super init];
    if (self) {
        _storage = storage;
        _logger = logger;

        id storedObject = [storage diskObjectForKey:OCB__SERVICE_NAME__StorageKey];
        if ([storedObject isKindOfClass:[NSDictionary class]]) {
            _state = [((NSDictionary *)storedObject) mutableCopy];
        } else {
            _state = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (NSDictionary<NSString *,id> *)allValues
{
    return [self.state copy];
}

- (nullable id)stateValueForKey:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }

    return self.state[key];
}

- (void)applyState:(NSDictionary<NSString *,id> *)state
{
    if (state.count == 0) {
        return;
    }

    [self.state addEntriesFromDictionary:state];
    [self persistState];
    [self.logger logWithLevel:OCBLogLevelInfo
                      message:[NSString stringWithFormat:@"__SERVICE_NAME__ service applied %lu state entries.", (unsigned long)state.count]];
    [self notifyStateDidChange];
}

- (void)setStateValue:(nullable id)value forKey:(NSString *)key
{
    if (key.length == 0) {
        return;
    }

    if (value == nil) {
        [self.state removeObjectForKey:key];
        [self.logger logWithLevel:OCBLogLevelDebug
                          message:[NSString stringWithFormat:@"__SERVICE_NAME__ removed key: %@", key]];
    } else {
        self.state[key] = value;
        [self.logger logWithLevel:OCBLogLevelDebug
                          message:[NSString stringWithFormat:@"__SERVICE_NAME__ updated key: %@", key]];
    }

    [self persistState];
    [self notifyStateDidChange];
}

- (void)persistState
{
    [self.storage setDiskObject:[self.state copy] forKey:OCB__SERVICE_NAME__StorageKey];
}

- (void)notifyStateDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OCB__SERVICE_NAME__DidChangeNotification
                                                        object:self
                                                      userInfo:nil];
}

@end
