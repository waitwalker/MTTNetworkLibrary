//
//  MTTNetworkDownloadEngine.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/3.
//

#import <MTTNetworkLibrary/MTTNetworkLibrary.h>
#import "MTTNetworkBaseEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkDownloadEngine : MTTNetworkBaseEngine


/// 下载请求
/// @param url url
/// @param ignoreBaseURL 是否忽略base url
/// @param downloadFilePath 下载文件路径
/// @param resumable 是否可恢复
/// @param backgroundSupport 是否支持后台下载
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString * _Nonnull)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
                   resumable:(BOOL)resumable
           backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 暂停所有下载
- (void)suspendAllDownloadRequests;


/// 根据url暂停某个下载请求
/// @param url url
- (void)suspendDownloadRequest:(NSString *_Nonnull)url;


/// 根据url暂停某个下载请求
/// @param url url
/// @param ignoreBaseURL 是否忽略base url
- (void)suspendDownloadRequest:(NSString *_Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url列表暂停所有下载任务
/// @param urls url列表
- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls;


/// 根据url列表暂停所有下载任务
/// @param urls url列表
/// @param ignoreBaseURL 是否忽略base url
- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 恢复所有下载任务
- (void)resumeAllDownloadRequests;


/// 根据url恢复下载请求
/// @param url url
- (void)resumeDownloadRequest:(NSString *_Nonnull)url;


/// 根据url恢复下载请求
/// @param url url
/// @param ignoreBaseURL 是否忽略base url
- (void)resumeDownloadRequest:(NSString *_Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url列表恢复所有下载请求
/// @param urls url列表
- (void)resumeDownloadRequests:(NSArray *_Nonnull)urls;


/// 根据url列表恢复所有下载请求
/// @param urls url列表
/// @param ignoreBaseURL 是否忽略base url
- (void)resumeDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 取消所有下载请求
- (void)cancelAllDownloadRequests;


/// 根据url取消下载请求
/// @param url url
- (void)cancelDownloadRequest:(NSString *_Nonnull)url;


/// 根据url取消下载请求
/// @param url url
/// @param ignoreBaseURL 是否忽略base url
- (void)cancelDownloadRequest:(NSString *_Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url列表取消所有下载请求
/// @param urls url列表
- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls;


/// 根据url列表取消锁下载请求
/// @param urls url 列表
/// @param ignoreBaseURL 是否忽略base url
- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url查询恢复数据比例
/// @param url url
- (CGFloat)resumeDataRadioOfRequest:(NSString *_Nonnull)url;


/// 根据url查询恢复数据比例
/// @param url url
/// @param ignoreBaseURL 是否忽略base url
- (CGFloat)resumeDataRadioOfRequest:(NSString *_Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;

@end

NS_ASSUME_NONNULL_END
