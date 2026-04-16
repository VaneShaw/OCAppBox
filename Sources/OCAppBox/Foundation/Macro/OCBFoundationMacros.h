#import <Foundation/Foundation.h>

#ifndef OCBFoundationMacros_h
#define OCBFoundationMacros_h

#define OCB_WEAKIFY(VAR) __weak typeof(VAR) weak##VAR = (VAR)
#define OCB_STRONGIFY(VAR) __strong typeof(weak##VAR) VAR = weak##VAR

#define OCB_SAFE_BLOCK(BLOCK, ...) \
    do { \
        if ((BLOCK) != nil) { \
            (BLOCK)(__VA_ARGS__); \
        } \
    } while (0)

#define OCB_DISPATCH_MAIN_ASYNC_SAFE(BLOCK) \
    do { \
        if ([NSThread isMainThread]) { \
            (BLOCK)(); \
        } else { \
            dispatch_async(dispatch_get_main_queue(), (BLOCK)); \
        } \
    } while (0)

#endif /* OCBFoundationMacros_h */
