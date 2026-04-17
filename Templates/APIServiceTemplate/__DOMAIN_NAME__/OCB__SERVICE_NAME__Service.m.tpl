#import "OCB__SERVICE_NAME__Service.h"

#import "OCBAutoRegister.h"

OCB_EXPORT_SERVICE(OCB__SERVICE_NAME__Providing, OCB__SERVICE_NAME__Service)

@implementation OCB__SERVICE_NAME__Service

- (void)fetch__SERVICE_NAME__WithCompletion:(OCB__SERVICE_NAME__Completion)completion
{
    // Replace the demo path and parameters with your real API contract.
    [self GET:@"/__SERVICE_ROUTE__" parameters:nil completion:completion];
}

@end
