//
//  NetworkLibraryCommon.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/5.
//

#ifndef NetworkLibraryCommon_h
#define NetworkLibraryCommon_h
#import <AFNetworking/AFNetworking.h>

/// 普通请求 回调
typedef void(^MTTSuccessBlock)(id responseObject);
typedef void(^MTTFailureBlock)(NSURLSessionTask *task, NSError *error, NSInteger statusCode);

/// 上传回调
typedef void(^MTTUploadSuccessBlock)(id responseObject);
typedef void(^MTTUploadProgressBlock)(NSProgress *uploadProgress);
typedef void(^MTTUploadFailureBlock)(NSURLSessionTask *task, NSError *error, NSInteger statusCode, NSArray<UIImage *> *uploadFailedImages);

/// 下载回调
typedef void(^MTTDownloadSuccessBlock)(id responseObject);
typedef void(^MTTDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);
typedef void(^MTTDownloadFailureBlock)(NSURLSessionTask *task, NSError *error, NSString *resumableDataPath);

/// 请求方法
typedef NS_ENUM(NSInteger, MTTRequestMethod) {
    MTTRequestMethodGet = 60000,
    MTTRequestMethodPost,
    MTTRequestMethodPut,
    MTTRequestMethodDelete,
};

/// 请求类型:普通,上传,下载
typedef NS_ENUM(NSInteger, MTTRequestType) {
    MTTRequestTypeOrdinary = 70000,
    MTTRequestTypeUpload,
    MTTRequestTypeDownload,
};

/// 下载任务操作状态
typedef NS_ENUM(NSInteger, MTTDownloadManualOperation) {
    MTTDownloadManualOperationStart = 80000,
    MTTDownloadManualOperationSuspend,
    MTTDownloadManualOperationResume,
    MTTDownloadManualOperationCancel,
};

#endif /* NetworkLibraryCommon_h */
