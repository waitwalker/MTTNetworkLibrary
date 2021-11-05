//
//  MTTNetworkRequestEngine.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/2.
//

#import <MTTNetworkLibrary/MTTNetworkLibrary.h>
#import "MTTNetworkBaseEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkRequestEngine : MTTNetworkBaseEngine


/// 发起普通请求
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString * _Nonnull)url
              method:(MTTRequestMethod)method
          parameters:(id _Nullable)parameters
           loadCache:(BOOL)loadCache
       cacheDuration:(NSTimeInterval)cacheDuration
             success:(MTTSuccessBlock _Nullable)successBlock
             failure:(MTTFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
