//
//  MTTNetworkManager.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/4.
//

#import <Foundation/Foundation.h>
#import "MTTNetworkRequestModel.h"
#import "MTTNetworkCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkManager : NSObject

+ (instancetype)sharedManager;
+ (instancetype)new NS_UNAVAILABLE;


/// 添加请求头
/// @param header 请求头
- (void)addCustomHeader:(NSDictionary *_Nonnull)header;


/// 获取请求头
- (NSDictionary *_Nullable)customHeaders;


/// 发送get请求
/// @param url 请求url
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchGetRequest:(NSString *_Nonnull)url
                success:(MTTSuccessBlock _Nullable)successBlock
                failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送get请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchGetRequest:(NSString *_Nonnull)url
             parameters:(id _Nullable)parameters
                success:(MTTSuccessBlock _Nullable)successBlock
                failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送get请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchGetRequest:(NSString *_Nonnull)url
             parameters:(id _Nullable)parameters
              loadCache:(BOOL)loadCache
                success:(MTTSuccessBlock _Nullable)successBlock
                failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送get请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchGetRequest:(NSString *_Nonnull)url
             parameters:(id _Nullable)parameters
              cacheDuration:(NSTimeInterval)cacheDuration
                success:(MTTSuccessBlock _Nullable)successBlock
                failure:(MTTFailureBlock _Nullable)failureBlock;

/// 发送get请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchGetRequest:(NSString *_Nonnull)url
             parameters:(id _Nullable)parameters
              loadCache:(BOOL)loadCache
              cacheDuration:(NSTimeInterval)cacheDuration
                success:(MTTSuccessBlock _Nullable)successBlock
                failure:(MTTFailureBlock _Nullable)failureBlock;



/// 发送post请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPostRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送post请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPostRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送post请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPostRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送post请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 缓存时间
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPostRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送put请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPutRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送put请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPutRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送put请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPutRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送put请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 缓存时间
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchPutRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;

/// 发送delete请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchDeleteRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送delete请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchDeleteRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送delete请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchDeleteRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送delete请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 缓存时间
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchDeleteRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送常规请求 参数为空时.默认GET请求,参数非空时,默认POST请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送常规请求 参数为空时.默认GET请求,参数非空时,默认POST请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送常规请求 参数为空时.默认GET请求,参数非空时,默认POST请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 发送常规请求 参数为空时.默认GET请求,参数非空时,默认POST请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param loadCache 缓存时间
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;

/// 根据请求方法发送常规请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param method 请求方法
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              method:(MTTRequestMethod)method
              parameters:(id _Nullable)parameters
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 根据请求方法发送常规请求
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param loadCache 是否加载缓存
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              method:(MTTRequestMethod)method
          parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 根据请求方法发送常规请求
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              method:(MTTRequestMethod)method
              parameters:(id _Nullable)parameters
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 根据请求方法发送常规请求
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param loadCache 缓存时间
/// @param cacheDuration 缓存时间
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)fetchRequest:(NSString *_Nonnull)url
              method:(MTTRequestMethod)method
              parameters:(id _Nullable)parameters
               loadCache:(BOOL)loadCache
               cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock _Nullable)successBlock
                 failure:(MTTFailureBlock _Nullable)failureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param image 图片
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImageRequest:(NSString *_Nonnull)url
                     parameters:(id _Nullable)parameters
                          image:(UIImage *_Nonnull)image
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param ignoreBaseURL 是否忽略base url
/// @param parameters 请求参数
/// @param image 图片
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImageRequest:(NSString *_Nonnull)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id _Nullable)parameters
                          image:(UIImage *_Nonnull)image
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;

/// 上传图片请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param images 图片列表
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImagesRequest:(NSString *_Nonnull)url
                     parameters:(id _Nullable)parameters
                          images:(NSArray<UIImage *> *_Nonnull)images
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param ignoreBaseURL 是否忽略base url
/// @param parameters 请求参数
/// @param images 图片列表
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImagesRequest:(NSString *_Nonnull)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id _Nullable)parameters
                          images:(NSArray<UIImage *> *_Nonnull)images
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param image 图片
/// @param compressRatio 图片压缩比例
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImageRequest:(NSString *_Nonnull)url
                     parameters:(id _Nullable)parameters
                          image:(UIImage *_Nonnull)image
                  compressRatio:(float)compressRatio
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param ignoreBaseURL 是否忽略base url
/// @param parameters 请求参数
/// @param image 图片
/// @param compressRatio 图片压缩比例
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImageRequest:(NSString *_Nonnull)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id _Nullable)parameters
                          image:(UIImage *_Nonnull)image
                  compressRatio:(float)compressRatio
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param parameters 请求参数
/// @param images 图片列表
/// @param compressRatio 图片压缩比例
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImagesRequest:(NSString *_Nonnull)url
                     parameters:(id _Nullable)parameters
                          images:(NSArray<UIImage *> *_Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 上传图片请求
/// @param url 请求url
/// @param ignoreBaseURL 是否忽略base url
/// @param parameters 请求参数
/// @param images 图片列表
/// @param compressRatio 图片压缩比例
/// @param name 请求id
/// @param mimeType 网络媒体类型
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImagesRequest:(NSString *_Nonnull)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id _Nullable)parameters
                          images:(NSArray<UIImage *> *_Nonnull)images
                  compressRatio:(float)compressRatio
                           name:(NSString *_Nullable)name
                       mimeType:(NSString *_Nullable)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param downloadFilePath 文件缓存路径
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param ignoreBaseURL 是否忽略base url
/// @param downloadFilePath 文件缓存路径
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param downloadFilePath 文件缓存路径
/// @param resumable 是否可恢复
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
               resumable:(BOOL)resumable
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param ignoreBaseURL 是否忽略base url
/// @param downloadFilePath 文件缓存路径
/// @param resumable 是否可恢复
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
                   resumable:(BOOL)resumable
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param downloadFilePath 文件缓存路径
/// @param backgroundSupport 是否支持后台下载
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
               backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param ignoreBaseURL 是否忽略base url
/// @param downloadFilePath 文件缓存路径
/// @param backgroundSupport 是否支持后台下载
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
               backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param downloadFilePath 文件缓存路径
/// @param resumable 是否可恢复
/// @param backgroundSupport 是否支持后台下载
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
                   resumable:(BOOL)resumable
               backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 下载请求
/// @param url 请url
/// @param ignoreBaseURL 是否忽略base url
/// @param downloadFilePath 文件缓存路径
/// @param resumable 是否可恢复
/// @param backgroundSupport 是否支持后台下载
/// @param downloadProgressBlock 下载进度回调
/// @param downloadSuccessBlock 下载成功回调
/// @param downloadFailureBlock 下载失败回调
- (void)fetchDownloadRequest:(NSString *_Nonnull)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *_Nonnull)downloadFilePath
                   resumable:(BOOL)resumable
               backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock _Nullable)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock _Nullable)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock _Nullable)downloadFailureBlock;


/// 暂停所有下载任务
- (void)suspendAllDownloadRequests;


/// 根据url暂停某个下载任务
/// @param url 下载url
- (void)suspendDownloadRequest:(NSString * _Nonnull)url;


/// 根据url暂停某个下载任务
/// @param url 下载url
/// @param ignoreBaseURL 是否忽略base url
- (void)suspendDownloadRequest:(NSString * _Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url列表暂停所有下载任务
/// @param urls url列表
- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls;


/// 根据url列表暂停所有下载任务
/// @param urls url列表
/// @param ignoreBaseURL 是否忽略base url
- (void)suspendDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 恢复所有的下载任务
- (void)resumeAllDownloadRequests;


/// 根据url恢复某个下载任务
/// @param url 下载url
- (void)resumeDownloadRequest:(NSString * _Nonnull)url;


/// 根据url恢复某个下载任务
/// @param url 下载url
/// @param ignoreBaseURL 是否忽略base url
- (void)resumeDownloadRequest:(NSString * _Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url列表恢复所有下载任务
/// @param urls url列表
- (void)resumeDownloadRequests:(NSArray *_Nonnull)urls;


/// 根据url列表恢复所有下载任务
/// @param urls url列表
/// @param ignoreBaseURL 是否忽略base url
- (void)resumeDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 取消所有的下载任务
- (void)cancelAllDownloadRequests;


/// 根据url取消某个下载任务
/// @param url 下载url
- (void)cancelDownloadRequest:(NSString * _Nonnull)url;


/// 根据url取消某个下载任务
/// @param url 下载url
/// @param ignoreBaseURL 是否忽略base url
- (void)cancelDownloadRequest:(NSString * _Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url列表取消所有下载任务
/// @param urls url列表
- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls;


/// 根据url列表取消所有下载任务
/// @param urls url列表
/// @param ignoreBaseURL 是否忽略base url
- (void)cancelDownloadRequests:(NSArray *_Nonnull)urls ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 根据url恢复下载数据比例
/// @param url url
- (CGFloat)resumeDataRatioOfRequest:(NSString *_Nonnull)url;


/// 根据url恢复下载数据比例
/// @param url 请求url
/// @param ignoreBaseURL 是否忽略base URL
- (CGFloat)resumeDataRatioOfRequest:(NSString *_Nonnull)url ignoreBaseURL:(BOOL)ignoreBaseURL;


/// 取消当前所有请求
- (void)cancelAllCurrentRequest;


/// 根据url取消当前下载
/// @param url 请求url
- (void)cancelCurrentRequestWithURL:(NSString * _Nonnull)url;


/// 根据url等取消当前下载
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
- (void)cancelCurrentRequestWithURL:(NSString * _Nonnull)url
                             method:(NSString *_Nonnull)method
                         parameters:(id _Nullable)parameters;



/// 根据url加载缓存
/// @param url 请求url
/// @param completionBlock 缓存回调
- (void)loadCacheWithURL:(NSString * _Nonnull)url
         completionBlock:(MTTLoadCacheArrayCompletionBlock _Nullable)completionBlock;



/// 根据url等加载缓存
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param completionBlock 缓存回调
- (void)loadCacheWithURL:(NSString * _Nonnull)url
                  method:(NSString *_Nonnull)method
              parameters:(id _Nonnull)parameters
         completionBlock:(nonnull MTTLoadCacheCompletionBlock)completionBlock;

/// 根据url等加载缓存
/// @param url 请求url
/// @param method 请求方法
/// @param completionBlock 缓存回调
- (void)loadCacheWithURL:(NSString * _Nonnull)url
                  method:(NSString *_Nonnull)method
         completionBlock:(nonnull MTTLoadCacheCompletionBlock)completionBlock;


/// 计算缓存大小
/// @param completionBlock 缓存大小回调
- (void)calculateCacheSizeCompletionBlock:(MTTCalculateSizeCompletionBlock _Nullable)completionBlock;


/// 清除所有缓存
/// @param completionBlock 清除缓存回调
- (void)clearAllCacheCompletionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 根据url清除缓存
/// @param url 请求url
/// @param completionBlock 清除缓存回调
- (void)clearCacheWithURL:(NSString *_Nonnull)url
          completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 根据url等清除缓存
/// @param url 请求url
/// @param method 请求方法
/// @param completionBlock 清除缓存回调
- (void)clearCacheWithURL:(NSString *_Nonnull)url
                   method:(NSString * _Nonnull)method
          completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 根据url等清除缓存
/// @param url 请求url
/// @param method 请求方法
/// @param parameters 请求参数
/// @param completionBlock 清除缓存回调
- (void)clearCacheWithURL:(NSString *)url
                   method:(NSString *)method
               parameters:(id _Nullable)parameters
          completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock;


/// 打印所有请求
- (void)printAllCurrentRequests;


/// 当前是否还有请求
- (BOOL)remainingCurrentRequests;


/// 当前请求数量
- (NSInteger)currentRequestCount;

@end

NS_ASSUME_NONNULL_END
