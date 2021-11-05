//
//  MTTNetworkConfig.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkConfig : NSObject

/// base url
@property (nonatomic, strong) NSString *_Nullable baseUrl;

/// 默认参数
@property (nonatomic, strong) NSDictionary *_Nullable defaultParameters;

/// 请求头
@property (nonatomic, readonly, strong) NSDictionary * _Nullable customHeaders;

/// 超时时间 默认 20
@property (nonatomic, assign) NSTimeInterval timeoutSeconds;

/// 是否debug 模式
@property (nonatomic, assign) BOOL debugMode;


/// 单例
+ (instancetype)sharedConfig;


/// 添加请求头
/// @param header 请求头
- (void)addCustomHeader:(NSDictionary *_Nonnull)header;


@end

NS_ASSUME_NONNULL_END
