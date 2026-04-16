#import "OCBModuleManager.h"

#import "OCBAppContext.h"
#import "OCBAutoRegister.h"
#import "OCBLaunchTask.h"
#import "OCBModuleProtocol.h"
#import "OCBRouter.h"
#import "OCBServiceRegistry.h"

@interface OCBModuleManager ()

@property (nonatomic, weak) OCBAppContext *appContext;
@property (nonatomic, strong) NSMutableArray<id<OCBModuleProtocol>> *mutableModules;

@end

@implementation OCBModuleManager

- (instancetype)initWithAppContext:(OCBAppContext *)appContext
{
    NSParameterAssert(appContext != nil);

    self = [super init];
    if (self) {
        _appContext = appContext;
        _mutableModules = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<id<OCBModuleProtocol>> *)modules
{
    return [self.mutableModules copy];
}

- (void)registerModule:(id<OCBModuleProtocol>)module
{
    if (module == nil) {
        return;
    }

    for (id<OCBModuleProtocol> existingModule in self.mutableModules) {
        if ([existingModule class] == [module class]) {
            return;
        }
    }

    [self.mutableModules addObject:module];

    if ([module respondsToSelector:@selector(registerServicesWithServiceRegistry:)]) {
        [module registerServicesWithServiceRegistry:self.appContext.serviceRegistry];
    }

    if ([module respondsToSelector:@selector(registerRoutesWithRouter:)]) {
        [module registerRoutesWithRouter:self.appContext.router];
    }

    if ([module respondsToSelector:@selector(moduleDidRegisterWithContext:)]) {
        [module moduleDidRegisterWithContext:self.appContext];
    }
}

- (void)autoRegisterModules
{
    for (Class moduleClass in OCBAllRegisteredModuleClasses()) {
        if (![moduleClass conformsToProtocol:@protocol(OCBModuleProtocol)]) {
            continue;
        }

        id<OCBModuleProtocol> module = [[moduleClass alloc] init];
        [self registerModule:module];
    }
}

- (void)startWithLaunchOptions:(nullable NSDictionary *)launchOptions
{
    NSMutableArray<id<OCBLaunchTask>> *tasks = [[NSMutableArray alloc] init];

    for (id<OCBModuleProtocol> module in self.mutableModules) {
        if (![module respondsToSelector:@selector(launchTasks)]) {
            continue;
        }

        NSArray<id<OCBLaunchTask>> *moduleTasks = [module launchTasks];
        if (moduleTasks.count > 0) {
            [tasks addObjectsFromArray:moduleTasks];
        }
    }

    NSArray<id<OCBLaunchTask>> *sortedTasks = [tasks sortedArrayUsingComparator:^NSComparisonResult(id<OCBLaunchTask> lhs, id<OCBLaunchTask> rhs) {
        if (lhs.stage < rhs.stage) {
            return NSOrderedAscending;
        }
        if (lhs.stage > rhs.stage) {
            return NSOrderedDescending;
        }
        if (lhs.priority > rhs.priority) {
            return NSOrderedAscending;
        }
        if (lhs.priority < rhs.priority) {
            return NSOrderedDescending;
        }
        return [lhs.taskIdentifier compare:rhs.taskIdentifier];
    }];

    for (id<OCBLaunchTask> task in sortedTasks) {
        [task performWithAppContext:self.appContext launchOptions:launchOptions];
    }
}

@end
