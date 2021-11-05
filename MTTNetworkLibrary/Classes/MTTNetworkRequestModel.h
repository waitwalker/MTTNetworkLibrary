//
//  MTTNetworkReuestModel.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/27.
//

#import <Foundation/Foundation.h>
#import "NetworkLibraryCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkRequestModel : NSObject

/// 请求的id
@property (nonatomic, copy) NSString *requestIdentifer;

/// request dask (NSURLSessionDataTask 或者 NSURLSessionDownloadTask)
@property (nonatomic, strong) NSURLSessionTask *task;

/// NSHTTPURLResponse 实例
@property (nonatomic, strong) NSURLResponse *response;

/// 请求url
@property (nonatomic, copy) NSString *requestUrl;

/// 是否忽略base url
@property (nonatomic, assign) BOOL ignoreBaseUrl;

/// 请求方法
@property (nonatomic, copy) NSString *method;

/// 响应object
@property (nonatomic, strong) id responseObject;


/// 请求参数
@property (nonatomic, strong) id parameters;

/// 是否加载缓存 默认false
@property (nonatomic, assign) BOOL loadCache;

/// 缓存失效时间
@property (nonatomic, assign) NSTimeInterval cacheDuration;

/// 请求响应
@property (nonatomic, strong) NSData *responseData;

/// 请求成功回调
@property (nonatomic, copy) MTTSuccessBlock successBlock;

/// 请求失败回调
@property (nonatomic, copy) MTTFailureBlock failureBlock;


/// 上传url
@property (nonatomic, copy) NSString *uploadUrl;

/// 上传图片列表
@property (nonatomic, strong) NSArray<UIImage *>*uploadImages;

/// 图片id
@property (nonatomic, copy) NSString *imageIdentier;

/// media 类型
@property (nonatomic, copy) NSString *mimeType;

/// 图片压缩比例
@property (nonatomic, assign) float imageCompressRatio;

/// 缓存文件路径
@property (nonatomic, readonly, copy) NSString *cacheDataFilePath;

/// 缓存文件数据信息路径
@property (nonatomic, readonly, copy) NSString *cacheDataInfoFilePath;

/// 上传文件成功回调
@property (nonatomic, copy) MTTUploadSuccessBlock uploadSuccessBlock;

/// 上传文件进度回调
@property (nonatomic, copy) MTTUploadProgressBlock uploadProgressBlock;

/// 上传文件失败回调
@property (nonatomic, copy) MTTUploadFailureBlock uploadFailureBlock;



/// 下载路径
@property (nonatomic, copy) NSString *downloadFilePath;

/// 是否可重新启动下载
@property (nonatomic, assign) BOOL resumableDownload;

/// 是否支持后台下载
@property (nonatomic, assign) BOOL backgroundDownloadSupport;

/// 文件输出流
@property (nonatomic,readwrite, strong) NSOutputStream *_Nullable stream;

/// 文件总长度
@property (nonatomic, assign) NSInteger totalLength;

/// 文件恢复路径
@property (nonatomic, readonly, copy) NSString *resumeDataFilePath;

/// 信息文件恢复路径
@property (nonatomic, readonly, copy) NSString *resumeDataInfoFilePath;

/// 请求操作类型
@property (nonatomic, assign) MTTDownloadManualOperation manualOperation;

/// 成功下载回调
@property (nonatomic, copy) MTTDownloadSuccessBlock downloadSuccessBlock;

/// 下载进度回调
@property (nonatomic, copy) MTTDownloadProgressBlock downloadProgressBlock;

/// 下载失败回调
@property (nonatomic, copy) MTTDownloadFailureBlock downloadFailureBlock;



/// 获取请求类型
- (MTTRequestType)requestType;


/// 获取文件缓存路径  只有普通请求才有缓存
- (NSString *)cacheDataFilePath;


/// 获取缓存info文件路径
- (NSString *)cacheDataInfoFilePath;


/// 重新启动文件缓存路径
- (NSString *)resumeDataFilePath;


/// 重新启动Info文件缓存路径
- (NSString *)resumeDataInfoFilePath;


/// 清空所有回调
- (void)clearAllBlocks;

@end

NS_ASSUME_NONNULL_END
