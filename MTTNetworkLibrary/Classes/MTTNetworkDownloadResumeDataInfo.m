//
//  MTTNetworkDownloadResumeDataInfo.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/29.
//

#import "MTTNetworkDownloadResumeDataInfo.h"

@implementation MTTNetworkDownloadResumeDataInfo

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.resumeDataLength forKey:NSStringFromSelector(@selector(resumeDataLength))];
    [coder encodeObject:self.totalDataLength forKey:NSStringFromSelector(@selector(totalDataLength))];
    [coder encodeObject:self.resumeDataRatio forKey:NSStringFromSelector(@selector(resumeDataRatio))];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.resumeDataRatio = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(resumeDataRatio))];
        self.resumeDataLength = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(resumeDataLength))];
        self.totalDataLength = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(totalDataLength))];
    }
    return self;
}

/// 重写协议方法
+ (BOOL)supportsSecureCoding {
    return true;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>:{resume data length:%@}, {total data length:%@}, {ratio:%@}", NSStringFromClass([self class]),self, _resumeDataLength, _totalDataLength, _resumeDataRatio];
}

@end
