//
//  MTTNetworkRequestPool.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/1.
//

#import <Foundation/Foundation.h>
#import "MTTNetworkRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableDictionary<NSString *, MTTNetworkRequestModel *> MTTCurrentRequestModels;

@interface MTTNetworkRequestPool : NSObject

+ (instancetype)sharedPool;



/// 获取当前请求池
- (MTTCurrentRequestModels *_Nonnull)currentRequestModels;

/// 添加请求model
/// @param requestModel 请求model
- (void)addRequestModel:(MTTNetworkRequestModel *_Nonnull)requestModel;


/// 移除请求model
/// @param requestModel 请求model
- (void)removeRequestModel:(MTTNetworkRequestModel *_Nonnull)requestModel;


/// 更改请求model
/// @param requestModel 请求model
/// @param key key
- (void)changeRequestModel:(MTTNetworkRequestModel *_Nonnull)requestModel forKey:(NSString *_Nonnull)key;


/// 检查当前是否存在请求
- (BOOL)remainingCurrentRequests;


/// 当前请求数量
- (NSInteger)currentRequestCount;


/// 打印所有请求信息
- (void)printAllCurrentRequests;


/// 取消所有目前的请求
- (void)cancelAllCurrentRequests;


/// 根据特定的url取消请求
/// @param url 请求url
- (void)cancelCurrentRequestWithURL:(NSString *_Nonnull)url;


/// 根据给定的一组url取消请求
/// @param urls 给定的url列表
- (void)cancelCurrentRequestWithURLS:(NSArray *_Nonnull)urls;


/// 根据给定的请求相关信息取消请求
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
- (void)cancelCurrentRequestWithURL:(NSString *_Nonnull)url
                             method:(NSString *_Nonnull)method
                         parameters:(id _Nonnull)parameters;

@end

NS_ASSUME_NONNULL_END
