//
//  MTTNetworkDownloadResumeDataInfo.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkDownloadResumeDataInfo : NSObject<NSSecureCoding>

/// 要恢复下载数据长度
@property (nonatomic, copy) NSString *resumeDataLength;

/// 数据总长度
@property (nonatomic, copy) NSString *totalDataLength;

/// 要恢复数据所占比例
@property (nonatomic, copy) NSString *resumeDataRatio;

@end

NS_ASSUME_NONNULL_END
