#import "OCBBaseAPIService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^OCB__SERVICE_NAME__Completion)(id _Nullable data,
                                              OCBNetworkResponse * _Nullable response,
                                              NSError * _Nullable error);

@protocol OCB__SERVICE_NAME__Providing <NSObject>

- (void)fetch__SERVICE_NAME__WithCompletion:(OCB__SERVICE_NAME__Completion)completion;

@end

@interface OCB__SERVICE_NAME__Service : OCBBaseAPIService <OCB__SERVICE_NAME__Providing>

@end

NS_ASSUME_NONNULL_END
