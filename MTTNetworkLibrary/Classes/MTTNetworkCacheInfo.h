//
//  MTTNetworkCacheInfo.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkCacheInfo : NSObject<NSSecureCoding>

/// 创建日期
@property (nonatomic, strong) NSDate *createDate;

/// 缓存时间
@property (nonatomic, strong) NSNumber *cacheDuration;

/// app 版本
@property (nonatomic, copy) NSString *appVersion;

/// 请求id
@property (nonatomic, copy) NSString *requestIdentifer;

@end

NS_ASSUME_NONNULL_END
