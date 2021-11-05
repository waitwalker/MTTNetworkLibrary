//
//  MTTNetworkManager.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/4.
//

#import "MTTNetworkManager.h"
#import "MTTNetworkConfig.h"
#import "MTTNetworkRequestPool.h"
#import "MTTNetworkRequestEngine.h"
#import "MTTNetworkUploadEngine.h"
#import "MTTNetworkDownloadEngine.h"


@interface MTTNetworkManager ()
@property (nonatomic, strong) MTTNetworkRequestEngine *requestEngine;
@property (nonatomic, strong) MTTNetworkUploadEngine *uploadEngine;
@property (nonatomic, strong) MTTNetworkDownloadEngine *downloadEngine;
@property (nonatomic, strong) MTTNetworkRequestPool *requestPool;
@property (nonatomic, strong) MTTNetworkCacheManager *cacheManager;
@end


@implementation MTTNetworkManager

+ (instancetype)sharedManager {
    static MTTNetworkManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MTTNetworkManager alloc]init];
    });
    return instance;
}

- (MTTNetworkRequestEngine *)requestEngine {
    if (!_requestEngine) {
        _requestEngine = [[MTTNetworkRequestEngine alloc]init];
    }
    return _requestEngine;
}

- (MTTNetworkUploadEngine *)uploadEngine {
    if (!_uploadEngine) {
        _uploadEngine = [[MTTNetworkUploadEngine alloc]init];
    }
    return _uploadEngine;
}

- (MTTNetworkDownloadEngine *)downloadEngine {
    if (!_downloadEngine) {
        _downloadEngine = [[MTTNetworkDownloadEngine alloc]init];
    }
    return _downloadEngine;
}

- (MTTNetworkRequestPool *)requestPool {
    if (!_requestPool) {
        _requestPool = [MTTNetworkRequestPool sharedPool];
    }
    return _requestPool;
}

- (MTTNetworkCacheManager *)cacheManager {
    if (!_cacheManager) {
        _cacheManager = [MTTNetworkCacheManager sharedInstance];
    }
    return _cacheManager;
}

- (void)dealloc {
    [self cancelAllCurrentRequest];
}

- (void)addCustomHeader:(NSDictionary *)header {
    [[MTTNetworkConfig sharedConfig] addCustomHeader:header];
}

- (NSDictionary *)customHeaders {
    return [MTTNetworkConfig sharedConfig].customHeaders;
}

- (void)fetchGetRequest:(NSString *)url
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodGet
                          parameters:nil
                           loadCache:false
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchGetRequest:(NSString *)url
             parameters:(id)parameters
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodGet
                          parameters:parameters
                           loadCache:false
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchGetRequest:(NSString *)url
             parameters:(id)parameters
              loadCache:(BOOL)loadCache
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodGet
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchGetRequest:(NSString *)url
             parameters:(id)parameters
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodGet
                          parameters:parameters
                           loadCache:false
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchGetRequest:(NSString *)url
             parameters:(id)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodGet
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPostRequest:(NSString *)url
              parameters:(id)parameters
                 success:(MTTSuccessBlock)successBlock
                 failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPost
                          parameters:parameters
                           loadCache:false
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPostRequest:(NSString *)url
              parameters:(id)parameters
               loadCache:(BOOL)loadCache
                 success:(MTTSuccessBlock)successBlock
                 failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPost
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPostRequest:(NSString *)url
              parameters:(id)parameters
           cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock)successBlock
                 failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPost
                          parameters:parameters
                           loadCache:false
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}


- (void)fetchPostRequest:(NSString *)url
              parameters:(id)parameters
               loadCache:(BOOL)loadCache
           cacheDuration:(NSTimeInterval)cacheDuration
                 success:(MTTSuccessBlock)successBlock
                 failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPost
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPutRequest:(NSString *)url
             parameters:(id)parameters
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPut
                          parameters:parameters
                           loadCache:false
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPutRequest:(NSString *)url
             parameters:(id)parameters
              loadCache:(BOOL)loadCache
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPut
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPutRequest:(NSString *)url
             parameters:(id)parameters
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPut
                          parameters:parameters
                           loadCache:false
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchPutRequest:(NSString *)url
             parameters:(id)parameters
              loadCache:(BOOL)loadCache
          cacheDuration:(NSTimeInterval)cacheDuration
                success:(MTTSuccessBlock)successBlock
                failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPut
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchDeleteRequest:(NSString *)url
                parameters:(id)parameters
                   success:(MTTSuccessBlock)successBlock
                   failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodDelete
                          parameters:parameters
                           loadCache:false
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchDeleteRequest:(NSString *)url
                parameters:(id)parameters
                 loadCache:(BOOL)loadCache
                   success:(MTTSuccessBlock)successBlock
                   failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodDelete
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchDeleteRequest:(NSString *)url
                parameters:(id)parameters
             cacheDuration:(NSTimeInterval)cacheDuration
                   success:(MTTSuccessBlock)successBlock
                   failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodDelete
                          parameters:parameters
                           loadCache:false
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchDeleteRequest:(NSString *)url
                parameters:(id)parameters
                 loadCache:(BOOL)loadCache
             cacheDuration:(NSTimeInterval)cacheDuration
                   success:(MTTSuccessBlock)successBlock
                   failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodDelete
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchRequest:(NSString *)url
          parameters:(id)parameters
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    if (parameters) {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodPost
                              parameters:parameters
                               loadCache:false
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
    } else {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodGet
                              parameters:nil
                               loadCache:false
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
    }
}

- (void)fetchRequest:(NSString *)url
          parameters:(id)parameters
           loadCache:(BOOL)loadCache
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    if (parameters) {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodPost
                              parameters:parameters
                               loadCache:loadCache
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
    } else {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodGet
                              parameters:nil
                               loadCache:loadCache
                           cacheDuration:0
                                 success:successBlock
                                 failure:failureBlock];
    }
}

- (void)fetchRequest:(NSString *)url
          parameters:(id)parameters
       cacheDuration:(NSTimeInterval)cacheDuration
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    if (parameters) {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodPost
                              parameters:parameters
                               loadCache:false
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    } else {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodGet
                              parameters:nil
                               loadCache:false
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    }
}

- (void)fetchRequest:(NSString *)url
          parameters:(id)parameters
           loadCache:(BOOL)loadCache
       cacheDuration:(NSTimeInterval)cacheDuration
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    if (parameters) {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodPost
                              parameters:parameters
                               loadCache:loadCache
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    } else {
        [self.requestEngine fetchRequest:url
                                  method:MTTRequestMethodGet
                              parameters:nil
                               loadCache:loadCache
                           cacheDuration:cacheDuration
                                 success:successBlock
                                 failure:failureBlock];
    }
}

- (void)fetchRequest:(NSString *)url
              method:(MTTRequestMethod)method
          parameters:(id)parameters
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:method
                          parameters:parameters
                           loadCache:false
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchRequest:(NSString *)url
              method:(MTTRequestMethod)method
          parameters:(id)parameters
           loadCache:(BOOL)loadCache
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:method
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:0
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchRequest:(NSString *)url
              method:(MTTRequestMethod)method
          parameters:(id)parameters
       cacheDuration:(NSTimeInterval)cacheDuration
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:MTTRequestMethodPost
                          parameters:parameters
                           loadCache:false
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchRequest:(NSString *)url
              method:(MTTRequestMethod)method
          parameters:(id)parameters
           loadCache:(BOOL)loadCache
       cacheDuration:(NSTimeInterval)cacheDuration
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    [self.requestEngine fetchRequest:url
                              method:method
                          parameters:parameters
                           loadCache:loadCache
                       cacheDuration:cacheDuration
                             success:successBlock
                             failure:failureBlock];
}

- (void)fetchUploadImageRequest:(NSString *)url
                     parameters:(id)parameters
                          image:(UIImage *)image
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(MTTUploadProgressBlock)uploadProgressBlock
                        success:(MTTUploadSuccessBlock)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:false
                                    parameters:parameters
                                        images:@[image]
                                 compressRatio:1
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImageRequest:(NSString *)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id)parameters
                          image:(UIImage *)image
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(MTTUploadProgressBlock)uploadProgressBlock
                        success:(MTTUploadSuccessBlock)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:ignoreBaseURL
                                    parameters:parameters
                                        images:@[image]
                                 compressRatio:1
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImagesRequest:(NSString *)url
                      parameters:(id)parameters
                          images:(NSArray<UIImage *> *)images
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                        progress:(MTTUploadProgressBlock)uploadProgressBlock
                         success:(MTTUploadSuccessBlock)uploadSuccessBlock
                         failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:false
                                    parameters:parameters
                                        images:images
                                 compressRatio:1
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImagesRequest:(NSString *)url
                   ignoreBaseURL:(BOOL)ignoreBaseURL
                      parameters:(id)parameters
                          images:(NSArray<UIImage *> *)images
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                        progress:(MTTUploadProgressBlock)uploadProgressBlock
                         success:(MTTUploadSuccessBlock)uploadSuccessBlock
                         failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:ignoreBaseURL
                                    parameters:parameters
                                        images:images
                                 compressRatio:1
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImageRequest:(NSString *)url
                     parameters:(id)parameters
                          image:(UIImage *)image
                  compressRatio:(float)compressRatio
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(MTTUploadProgressBlock)uploadProgressBlock
                        success:(MTTUploadSuccessBlock)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:false
                                    parameters:parameters
                                        images:@[image]
                                 compressRatio:compressRatio
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImageRequest:(NSString *)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id)parameters
                          image:(UIImage *)image
                  compressRatio:(float)compressRatio
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(MTTUploadProgressBlock)uploadProgressBlock
                        success:(MTTUploadSuccessBlock)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:ignoreBaseURL
                                    parameters:parameters
                                        images:@[image]
                                 compressRatio:compressRatio
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImagesRequest:(NSString *)url
                      parameters:(id)parameters
                          images:(NSArray<UIImage *> *)images
                   compressRatio:(float)compressRatio
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                        progress:(MTTUploadProgressBlock)uploadProgressBlock
                         success:(MTTUploadSuccessBlock)uploadSuccessBlock
                         failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:false
                                    parameters:parameters
                                        images:images
                                 compressRatio:compressRatio
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchUploadImagesRequest:(NSString *)url
                   ignoreBaseURL:(BOOL)ignoreBaseURL
                      parameters:(id)parameters
                          images:(NSArray<UIImage *> *)images
                   compressRatio:(float)compressRatio
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                        progress:(MTTUploadProgressBlock)uploadProgressBlock
                         success:(MTTUploadSuccessBlock)uploadSuccessBlock
                         failure:(MTTUploadFailureBlock)uploadFailureBlock {
    [self.uploadEngine fetchUploadImageRequest:url
                                 ignoreBaseURL:ignoreBaseURL
                                    parameters:parameters
                                        images:images
                                 compressRatio:compressRatio
                                          name:name
                                      mimeType:mimeType
                                      progress:uploadProgressBlock
                                       success:uploadSuccessBlock
                                       failure:uploadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
            downloadFilePath:(NSString *)downloadFilePath
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:false
                             downloadFilePath:downloadFilePath
                                    resumable:true
                            backgroundSupport:false
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *)downloadFilePath
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:ignoreBaseURL
                             downloadFilePath:downloadFilePath
                                    resumable:true
                            backgroundSupport:false
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
            downloadFilePath:(NSString *)downloadFilePath
                   resumable:(BOOL)resumable
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:false
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:false
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *)downloadFilePath
                   resumable:(BOOL)resumable
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:ignoreBaseURL
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:false
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
            downloadFilePath:(NSString *)downloadFilePath
           backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:false
                             downloadFilePath:downloadFilePath
                                    resumable:true
                            backgroundSupport:backgroundSupport
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *)downloadFilePath
           backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:ignoreBaseURL
                             downloadFilePath:downloadFilePath
                                    resumable:true
                            backgroundSupport:backgroundSupport
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
            downloadFilePath:(NSString *)downloadFilePath
                   resumable:(BOOL)resumable
           backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:false
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:backgroundSupport
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)fetchDownloadRequest:(NSString *)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *)downloadFilePath
                   resumable:(BOOL)resumable
           backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    [self.downloadEngine fetchDownloadRequest:url
                                ignoreBaseURL:ignoreBaseURL
                             downloadFilePath:downloadFilePath
                                    resumable:resumable
                            backgroundSupport:backgroundSupport
                                     progress:downloadProgressBlock
                                      success:downloadSuccessBlock
                                      failure:downloadFailureBlock];
}

- (void)suspendAllDownloadRequests {
    [self.downloadEngine suspendAllDownloadRequests];
}

- (void)suspendDownloadRequest:(NSString *)url {
    [self.downloadEngine suspendDownloadRequest:url];
}

- (void)suspendDownloadRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    [self.downloadEngine suspendDownloadRequest:url ignoreBaseURL:ignoreBaseURL];
}

- (void)suspendDownloadRequests:(NSArray *)urls {
    [self.downloadEngine suspendDownloadRequests:urls];
}

- (void)suspendDownloadRequests:(NSArray *)urls ignoreBaseURL:(BOOL)ignoreBaseURL {
    [self.downloadEngine suspendDownloadRequests:urls ignoreBaseURL:ignoreBaseURL];
}

- (void)resumeAllDownloadRequests {
    [self.downloadEngine resumeAllDownloadRequests];
}

- (void)resumeDownloadRequest:(NSString *)url {
    [self.downloadEngine resumeDownloadRequest:url];
}

- (void)resumeDownloadRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    [self.downloadEngine resumeDataRadioOfRequest:url ignoreBaseURL:ignoreBaseURL];
}

- (void)resumeDownloadRequests:(NSArray *)urls {
    [self.downloadEngine resumeDownloadRequests:urls];
}

- (void)resumeDownloadRequests:(NSArray *)urls ignoreBaseURL:(BOOL)ignoreBaseURL {
    [self.downloadEngine resumeDownloadRequests:urls ignoreBaseURL:ignoreBaseURL];
}

- (void)cancelAllDownloadRequests {
    [self.downloadEngine cancelAllDownloadRequests];
}

- (void)cancelDownloadRequest:(NSString *)url {
    [self.downloadEngine cancelDownloadRequest:url];
}

- (void)cancelDownloadRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    [self.downloadEngine cancelDownloadRequest:url ignoreBaseURL:ignoreBaseURL];
}

- (void)cancelDownloadRequests:(NSArray *)urls {
    [self.downloadEngine cancelDownloadRequests:urls];
}

- (void)cancelDownloadRequests:(NSArray *)urls ignoreBaseURL:(BOOL)ignoreBaseURL {
    [self.downloadEngine cancelDownloadRequests:urls ignoreBaseURL:ignoreBaseURL];
}

- (CGFloat)resumeDataRatioOfRequest:(NSString *)url {
    return [self.downloadEngine resumeDataRadioOfRequest:url];
}

- (CGFloat)resumeDataRatioOfRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    return [self.downloadEngine resumeDataRadioOfRequest:url ignoreBaseURL:ignoreBaseURL];
}

- (void)cancelAllCurrentRequest {
    [self.requestPool cancelAllCurrentRequests];
}

- (void)cancelCurrentRequestWithURL:(NSString *)url {
    [self.requestPool cancelCurrentRequestWithURL:url];
}

- (void)cancelCurrentRequestWithURL:(NSString *)url
                             method:(NSString *)method
                         parameters:(id)parameters {
    [self.requestPool cancelCurrentRequestWithURL:url
                                           method:method
                                       parameters:parameters];
}

- (void)printAllCurrentRequests {
    [self.requestPool printAllCurrentRequests];
}

- (BOOL)remainingCurrentRequests {
    return [self.requestPool remainingCurrentRequests];
}

- (NSInteger)currentRequestCount {
    return [self.requestPool currentRequestCount];
}

- (void)loadCacheWithURL:(NSString *)url completionBlock:(MTTLoadCacheArrayCompletionBlock)completionBlock {
    [self.cacheManager loadCacheWithURL:url completionBlock:completionBlock];
}

- (void)loadCacheWithURL:(NSString *)url
                  method:(NSString *)method
         completionBlock:(MTTLoadCacheCompletionBlock)completionBlock {
    [self.cacheManager loadCacheWithURL:url
                                 method:method
                        completionBlock:completionBlock];
}

- (void)loadCacheWithURL:(NSString *)url
                  method:(NSString *)method
              parameters:(id)parameters
         completionBlock:(MTTLoadCacheCompletionBlock)completionBlock {
    [self.cacheManager loadCacheWithURL:url
                                 method:method
                             parameters:parameters
                        completionBlock:completionBlock];
}

- (void)calculateCacheSizeCompletionBlock:(MTTCalculateSizeCompletionBlock)completionBlock {
    [self.cacheManager calculateAllCacheSize:completionBlock];
}

- (void)clearAllCacheCompletionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    [self.cacheManager clearAllCache:completionBlock];
}

- (void)clearCacheWithURL:(NSString *)url
          completionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    [self.cacheManager clearCacheWithURL:url
                         completionBlock:completionBlock];
}

- (void)clearCacheWithURL:(NSString *)url
                   method:(NSString *)method
          completionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    [self.cacheManager clearCacheWithURL:url
                                  method:method
                         completionBlock:completionBlock];
}

- (void)clearCacheWithURL:(NSString *)url
                   method:(NSString *)method
               parameters:(id)parameters
          completionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    [self.cacheManager clearCacheWithURL:url
                                  method:method
                              parameters:parameters
                         completionBlock:completionBlock];
}

@end
