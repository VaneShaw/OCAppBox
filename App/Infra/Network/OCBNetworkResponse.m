#import "OCBNetworkResponse.h"

#import "OCBAPIResponseMapper.h"

@implementation OCBNetworkResponse

- (instancetype)initWithRequestIdentifier:(NSString *)requestIdentifier
                               statusCode:(NSInteger)statusCode
                                  headers:(nullable NSDictionary<NSString *,id> *)headers
                           responseObject:(nullable id)responseObject
                                  rawData:(nullable NSData *)rawData
{
    self = [super init];
    if (self) {
        _requestIdentifier = [requestIdentifier copy] ?: @"";
        _statusCode = statusCode;
        _headers = [headers copy] ?: @{};
        _responseObject = responseObject;
        _rawData = rawData;
        _success = (statusCode >= 200 && statusCode < 300);
        OCBAPIResponseMapper *mapper = [OCBAPIResponseMapper sharedMapper];
        _hasBusinessEnvelope = [mapper hasBusinessEnvelopeInResponseObject:responseObject];
        _businessCode = [[mapper businessCodeFromResponseObject:responseObject] copy];
        _businessMessage = [[mapper businessMessageFromResponseObject:responseObject] copy];
        _businessData = [mapper businessDataFromResponseObject:responseObject];
        _businessSuccess = [mapper isBusinessSuccessForHTTPStatusCode:statusCode responseObject:responseObject];
    }
    return self;
}

@end
