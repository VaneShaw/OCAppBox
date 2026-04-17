#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCBAPIResponseMapper : NSObject

@property (nonatomic, copy) NSString *codeKeyPath;
@property (nonatomic, copy, nullable) NSString *messageKeyPath;
@property (nonatomic, copy, nullable) NSString *dataKeyPath;
@property (nonatomic, copy, nullable) NSString *successKeyPath;
@property (nonatomic, copy) NSArray<NSNumber *> *successCodes;
@property (nonatomic, assign) BOOL treatMissingBusinessCodeAsSuccess;

+ (instancetype)sharedMapper;

- (void)resetToDefaults;
- (BOOL)hasBusinessEnvelopeInResponseObject:(nullable id)responseObject;
- (nullable NSNumber *)businessCodeFromResponseObject:(nullable id)responseObject;
- (nullable NSString *)businessMessageFromResponseObject:(nullable id)responseObject;
- (nullable id)businessDataFromResponseObject:(nullable id)responseObject;
- (BOOL)isBusinessSuccessForHTTPStatusCode:(NSInteger)statusCode responseObject:(nullable id)responseObject;

@end

NS_ASSUME_NONNULL_END
