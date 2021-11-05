//
//  MTTNetworkCacheInfo.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/29.
//

#import "MTTNetworkCacheInfo.h"

@implementation MTTNetworkCacheInfo

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.cacheDuration forKey:NSStringFromSelector(@selector(cacheDuration))];
    [coder encodeObject:self.createDate forKey:NSStringFromSelector(@selector(createDate))];
    [coder encodeObject:self.appVersion forKey:NSStringFromSelector(@selector(appVersion))];
    [coder encodeObject:self.requestIdentifer forKey:NSStringFromSelector(@selector(requestIdentifer))];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.cacheDuration = [coder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(cacheDuration))];
        self.createDate = [coder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(createDate))];
        self.appVersion = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersion))];
        self.requestIdentifer = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(requestIdentifer))];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return true;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{cacheDuration:%@},{createDate:%@},{appVersion:%@},{requestIdentifer:%@}",NSStringFromClass([self class]),self,_cacheDuration,_createDate,_appVersion,_requestIdentifer];
}

@end
