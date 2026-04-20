#import "OCBBaseModel.h"

@implementation OCBBaseModel

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary
{
    self = [super init];
    if (self) {
        id mid = dictionary[@"id"];
        if ([mid isKindOfClass:[NSString class]]) {
            _modelIdentifier = [mid copy];
        } else if ([mid isKindOfClass:[NSNumber class]] || [mid isKindOfClass:[NSURL class]]) {
            _modelIdentifier = [[mid description] copy];
        }
    }
    return self;
}

- (instancetype)init
{
    return [self initWithDictionary:@{}];
}

- (NSDictionary<NSString *, id> *)toDictionary
{
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary dictionary];
    if (self.modelIdentifier.length > 0) {
        dict[@"id"] = self.modelIdentifier;
    }
    return [dict copy];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.modelIdentifier forKey:@"modelIdentifier"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self initWithDictionary:@{}];
    if (self) {
        _modelIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:@"modelIdentifier"];
    }
    return self;
}

@end
