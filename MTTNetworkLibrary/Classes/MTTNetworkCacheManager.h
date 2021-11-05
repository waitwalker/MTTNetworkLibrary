//
//  MTTNetworkCacheManager.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/29.
//

#import <Foundation/Foundation.h>
#import "MTTNetworkRequestModel.h"
#import "MTTNetworkDownloadResumeDataInfo.h"

/// 清除缓存回调
typedef void(^MTTClearCacheCompletionBlock)(BOOL isSuccess);

/// 加载缓存回调
typedef void(^MTTLoadCacheCompletionBlock)(id _Nullable cacheObject);

/// 加载缓存列表回调
typedef void(^MTTLoadCacheArrayCompletionBlock)(NSArray * _Nullable cacheArray);

/// 计算缓存数据空间回调
typedef void(^MTTCalculateSizeCompletionBlock)(NSUInteger fileCount, NSUInteger totalSize, NSString * _Nonnull totalSizeString);


NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkCacheManager : NSObject

+ (instancetype)sharedInstance;


/// 写入缓存
/// @param requestModel 请求model
/// @param asynchronously 是否同步
- (void)writeCacheWithRequestModel:(MTTNetworkRequestModel * _Nonnull)requestModel asynchrously:(BOOL)asynchronously;


/// 根据url加载缓存
/// @param url url
/// @param completionBlock 回调
- (void)loadCacheWithURL:(NSString * _Nonnull)url completionBlock:(MTTLoadCacheArrayCompletionBlock _Nullable)completionBlock;


/// 根据请求url和请求方法加载缓存
/// @param url url
/// @param method 请求方法
/// @param completionBlock 加载回调
- (void)loadCacheWithURL:(NSString *_Nonnull)url
                  method:(NSString *_Nonnull) method
         completionBlock:(MTTLoadCacheArrayCompletionBlock)completionBlock;


/// 根据url method parameters加载缓存
/// @param url url
/// @param method method
/// @param parameters parameters
/// @param completionBlock 加载回调
- (void)loadCacheWithURL:(NSString *_Nonnull)url
                  method:(NSString *_Nonnull) method
              parameters:(id _Nonnull)parameters
         completionBlock:(MTTLoadCacheCompletionBlock)completionBlock;


/// 根据请求id加载缓存
/// @param requestIdentifer 请求id
/// @param completionBlock 加载回调
- (void)loadCacheWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer completionBlock:(MTTLoadCacheCompletionBlock _Nullable)completionBlock;



/// 计算所有缓存空间大小
/// @param completionBlock 缓存空间大小回调
- (void)calculateAllCacheSize:(MTTCalculateSizeCompletionBlock _Nullable)completionBlock;


/// 清除所有缓存回调
/// @param completionBlock 清除缓存回调
- (void)clearAllCache:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 根据url清除特定缓存
/// @param url url
/// @param completionBlock 清除回调
- (void)clearCacheWithURL:(NSString * _Nonnull)url completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 根据请求url,请求方法清除缓存
/// @param url 请求url
/// @param method 请求方法
/// @param completionBlock 清除回调
- (void)clearCacheWithURL:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
          completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 根据请求url,方法,参数清除缓存
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param completionBlock 清除回调
- (void)clearCacheWithURL:(NSString * _Nonnull)url
                   method:(NSString * _Nonnull)method
               parameters:(id _Nullable)parameters
          completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 更新下载暂停后的数据信息
/// @param requestModel 请求model
- (void)updateResumeDataInfoAfterSuspendWithRequestModel:(MTTNetworkRequestModel * _Nonnull)requestModel;


/// 移除恢复数据和恢复info文件数据
/// @param requestModel 请求model
- (void)removeResumeDataAndResumeDataInfoFileWithRequestModel:(MTTNetworkRequestModel * _Nonnull)requestModel;


/// 移除下载数据&清空恢复信息文件
/// @param requestModel 请求model
- (void)removeCompletionDownloadDataAndClearResumeDataInfoFileWithRequestModel:(MTTNetworkRequestModel * _Nonnull)requestModel;


/// 根据文件加载恢复数据信息
/// @param filePath 文件
- (MTTNetworkDownloadResumeDataInfo *_Nullable)loadResumeDataInfo:(NSString *_Nonnull)filePath;
                          
@end

NS_ASSUME_NONNULL_END
