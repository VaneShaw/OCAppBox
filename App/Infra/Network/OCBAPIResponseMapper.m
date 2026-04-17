#import "OCBAPIResponseMapper.h"

#import "NSDictionary+OCBAdditions.h"
#import "NSString+OCBAdditions.h"

@implementation OCBAPIResponseMapper

+ (instancetype)sharedMapper
{
    static OCBAPIResponseMapper *mapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapper = [[OCBAPIResponseMapper alloc] init];
        [mapper resetToDefaults];
    });
    return mapper;
}

- (void)resetToDefaults
{
    self.codeKeyPath = @"code";
    self.messageKeyPath = @"message";
    self.dataKeyPath = @"data";
    self.successKeyPath = @"success";
    self.successCodes = @[@0, @200];
    self.treatMissingBusinessCodeAsSuccess = YES;
}

- (BOOL)hasBusinessEnvelopeInResponseObject:(nullable id)responseObject
{
    NSDictionary *responseDictionary = [self responseDictionaryFromResponseObject:responseObject];
    if (responseDictionary == nil) {
        return NO;
    }

    return [self hasValueForKeyPath:self.codeKeyPath inDictionary:responseDictionary]
        || [self hasValueForKeyPath:self.messageKeyPath inDictionary:responseDictionary]
        || [self hasValueForKeyPath:self.dataKeyPath inDictionary:responseDictionary]
        || [self hasValueForKeyPath:self.successKeyPath inDictionary:responseDictionary];
}

- (nullable NSNumber *)businessCodeFromResponseObject:(nullable id)responseObject
{
    NSDictionary *responseDictionary = [self responseDictionaryFromResponseObject:responseObject];
    if (responseDictionary == nil) {
        return nil;
    }

    id value = [responseDictionary ocb_objectForKeyPath:self.codeKeyPath];
    return [self numberFromObject:value];
}

- (nullable NSString *)businessMessageFromResponseObject:(nullable id)responseObject
{
    NSDictionary *responseDictionary = [self responseDictionaryFromResponseObject:responseObject];
    if (responseDictionary == nil || self.messageKeyPath.length == 0) {
        return nil;
    }

    return [responseDictionary ocb_stringForKeyPath:self.messageKeyPath defaultValue:nil];
}

- (nullable id)businessDataFromResponseObject:(nullable id)responseObject
{
    NSDictionary *responseDictionary = [self responseDictionaryFromResponseObject:responseObject];
    if (responseDictionary == nil) {
        return responseObject;
    }

    if ([self hasValueForKeyPath:self.dataKeyPath inDictionary:responseDictionary]) {
        return [responseDictionary ocb_objectForKeyPath:self.dataKeyPath];
    }

    return responseObject;
}

- (BOOL)isBusinessSuccessForHTTPStatusCode:(NSInteger)statusCode responseObject:(nullable id)responseObject
{
    if (statusCode < 200 || statusCode >= 300) {
        return NO;
    }

    NSDictionary *responseDictionary = [self responseDictionaryFromResponseObject:responseObject];
    if (responseDictionary == nil) {
        return YES;
    }

    NSNumber *explicitSuccess = [self explicitSuccessValueFromResponseObject:responseDictionary];
    if (explicitSuccess != nil) {
        return explicitSuccess.boolValue;
    }

    NSNumber *businessCode = [self businessCodeFromResponseObject:responseDictionary];
    if (businessCode != nil) {
        return [self.successCodes containsObject:businessCode];
    }

    return self.treatMissingBusinessCodeAsSuccess;
}

- (nullable NSDictionary *)responseDictionaryFromResponseObject:(nullable id)responseObject
{
    return [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil;
}

- (BOOL)hasValueForKeyPath:(nullable NSString *)keyPath inDictionary:(NSDictionary *)dictionary
{
    if (keyPath.length == 0) {
        return NO;
    }

    return [dictionary ocb_objectForKeyPath:keyPath] != nil;
}

- (nullable NSNumber *)explicitSuccessValueFromResponseObject:(NSDictionary *)responseDictionary
{
    if (self.successKeyPath.length == 0 || ![self hasValueForKeyPath:self.successKeyPath inDictionary:responseDictionary]) {
        return nil;
    }

    id value = [responseDictionary ocb_objectForKeyPath:self.successKeyPath];
    if ([value isKindOfClass:[NSNumber class]]) {
        return @([(NSNumber *)value boolValue]);
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *normalizedValue = [[(NSString *)value ocb_trimmedString] lowercaseString];
        if ([normalizedValue isEqualToString:@"true"] || [normalizedValue isEqualToString:@"yes"] || [normalizedValue isEqualToString:@"1"]) {
            return @YES;
        }
        if ([normalizedValue isEqualToString:@"false"] || [normalizedValue isEqualToString:@"no"] || [normalizedValue isEqualToString:@"0"]) {
            return @NO;
        }
    }

    return nil;
}

- (nullable NSNumber *)numberFromObject:(nullable id)object
{
    if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    }
    if ([object isKindOfClass:[NSString class]]) {
        NSString *stringValue = [(NSString *)object ocb_trimmedString];
        if (stringValue.length == 0) {
            return nil;
        }

        NSScanner *scanner = [NSScanner scannerWithString:stringValue];
        NSInteger parsedValue = 0;
        if ([scanner scanInteger:&parsedValue] && scanner.isAtEnd) {
            return @(parsedValue);
        }
    }

    return nil;
}

@end
