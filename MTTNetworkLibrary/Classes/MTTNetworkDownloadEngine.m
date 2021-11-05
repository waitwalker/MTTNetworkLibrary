//
//  MTTNetworkDownloadEngine.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/3.
//

#import "MTTNetworkDownloadEngine.h"
#import "MTTNetworkDownloadResumeDataInfo.h"
#import "MTTNetworkCacheManager.h"
#import "MTTNetworkRequestPool.h"
#import "MTTNetworkConfig.h"
#import "MTTNetworkUtils.h"
#import "MTTNetworkProtocol.h"

@interface MTTNetworkDownloadEngine ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate,MTTNetworkProtocol>

@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) NSURLSession *backgroundDownloadSession;
@property (nonatomic, strong) MTTNetworkCacheManager *cacheManager;

@end

@implementation MTTNetworkDownloadEngine {
    NSFileManager *_fileManager;
    BOOL _isDebugMode;
}

- (instancetype)init {
    if (self = [super init]) {
        _fileManager = [NSFileManager defaultManager];
        _isDebugMode = [MTTNetworkConfig sharedConfig].debugMode;
        _cacheManager = [MTTNetworkCacheManager sharedInstance];
    }
    return self;
}

- (void)dealloc {
    [_backgroundDownloadSession invalidateAndCancel];
    [_backgroundDownloadSession resetWithCompletionHandler:^{
        
    }];
    
    [_downloadSession invalidateAndCancel];
    [_downloadSession resetWithCompletionHandler:^{
        
    }];
}

- (NSURLSession *)downloadSession {
    static NSURLSession *downloadSession;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = [MTTNetworkConfig sharedConfig].timeoutSeconds;
        downloadSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return downloadSession;
}

- (NSURLSession *)backgroundDownloadSession {
    static NSURLSession *backgroundDownloadSession;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifer = @"kNetworkBackgroundSession_";
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifer];
        sessionConfig.timeoutIntervalForRequest = [MTTNetworkConfig sharedConfig].timeoutSeconds;
        backgroundDownloadSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return backgroundDownloadSession;
}

- (void)fetchDownloadRequest:(NSString *)url
               ignoreBaseURL:(BOOL)ignoreBaseURL
            downloadFilePath:(NSString *)downloadFilePath
                   resumable:(BOOL)resumable
           backgroundSupport:(BOOL)backgroundSupport
                    progress:(MTTDownloadProgressBlock)downloadProgressBlock
                     success:(MTTDownloadSuccessBlock)downloadSuccessBlock
                     failure:(MTTDownloadFailureBlock)downloadFailureBlock {
    NSString *fullURLStr = nil;
    NSString *requestIdentifer;
    if (ignoreBaseURL) {
        fullURLStr = url;
        requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:nil requestURL:url];
    } else {
        fullURLStr = [[MTTNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url];
    }
    
    /// 相关url的下载任务是否存在
    __block BOOL sameURLTaskExists = false;
    if ([[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        [[MTTNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj.requestUrl isEqualToString:fullURLStr]) {
                sameURLTaskExists = true;
                NSLog(@"下载任务不能启动,已经存在了相同url的下载任务:%@",fullURLStr);
                return;
            }
        }];
    }
    
    if (sameURLTaskExists) {
        return;
    }
    
    NSString *downloadTargetFilePath;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager]fileExistsAtPath:downloadFilePath isDirectory:&isDirectory]) {
        isDirectory = false;
    }
    
    if (isDirectory) {
        NSString *fileName = [fullURLStr lastPathComponent];
        downloadTargetFilePath = [NSString pathWithComponents:@[downloadFilePath, fileName]];
    } else {
        downloadTargetFilePath = downloadFilePath;
    }
    
    if ([_fileManager fileExistsAtPath:downloadTargetFilePath]) {
        [_fileManager removeItemAtPath:downloadTargetFilePath error:nil];
    }
    
    NSString *methodStr = @"GET";
    
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestModel alloc]init];
    requestModel.requestUrl = fullURLStr;
    requestModel.method = methodStr;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.downloadFilePath = downloadTargetFilePath;
    requestModel.resumableDownload = resumable;
    requestModel.backgroundDownloadSupport = backgroundSupport;
    requestModel.manualOperation = MTTDownloadManualOperationStart;
    requestModel.downloadSuccessBlock = downloadSuccessBlock;
    requestModel.downloadProgressBlock = downloadProgressBlock;
    requestModel.downloadFailureBlock = downloadFailureBlock;
    
    NSURLSessionTask *downloadTask;
    if (requestModel.backgroundDownloadSupport) {
        downloadTask = [self pBackgroundDownloadTaskWithRequestModel:requestModel];
    } else {
        downloadTask = [self pNoneBackgroundDownloadTaskWithRequestModel:requestModel];
    }
    requestModel.task = downloadTask;
    [[MTTNetworkRequestPool sharedPool]addRequestModel:requestModel];
    NSLog(@"开始下载------url:%@ downloadPath:%@",fullURLStr, requestModel.downloadFilePath);
    [downloadTask resume];
}

- (NSURLSessionTask *)pBackgroundDownloadTaskWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestModel.requestUrl]];
    [self pAddRequestHeaderInRequest:downloadRequest];
    
    NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
    NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
    
    if (![_fileManager fileExistsAtPath:resumeDataInfoFilePath]) {
        MTTNetworkDownloadResumeDataInfo *dataInfo = [[MTTNetworkDownloadResumeDataInfo alloc]init];
        [NSKeyedArchiver archiveRootObject:dataInfo toFile:resumeDataInfoFilePath];
    }
    
    NSURLSessionDownloadTask *downloadTask;
    if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
        if (resumeData) {
            if (requestModel.resumableDownload) {
                downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
            } else {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
                downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
            }
        } else {
            [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
        }
    } else {
        downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:downloadRequest];
    }
    return downloadTask;
}

- (void)pAddRequestHeaderInRequest:(NSMutableURLRequest *)request {
    NSDictionary *customHeaders = [MTTNetworkConfig sharedConfig].customHeaders;
    if (customHeaders.allKeys > 0) {
        [customHeaders enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull key, NSString  *_Nonnull value, BOOL * _Nonnull stop) {
            [request setValue:value forHTTPHeaderField:key];
            if (_isDebugMode) {
                NSLog(@"添加请求头key:%@,value:%@",key,value);
            }
        }];
    }
}

- (NSURLSessionTask *)pNoneBackgroundDownloadTaskWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    NSMutableURLRequest *downloadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestModel.requestUrl]];
    [self pAddRequestHeaderInRequest:downloadRequest];
    
    NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
    NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
    
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:resumeDataFilePath append:true];
    requestModel.stream = stream;
    
    if (requestModel.resumableDownload) {
        if ([_fileManager fileExistsAtPath:resumeDataInfoFilePath]) {
            MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:resumeDataInfoFilePath];
            
            if (dataInfo) {
                NSInteger resumeDataLength = [dataInfo.resumeDataLength integerValue];
                if (resumeDataLength > 0) {
                    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",resumeDataLength];
                    [downloadRequest setValue:range forHTTPHeaderField:@"Range"];
                }
            } else {
                if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                    [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
                }
            }
        } else {
            MTTNetworkDownloadResumeDataInfo *dataInfo = [[MTTNetworkDownloadResumeDataInfo alloc]init];
            [NSKeyedArchiver archiveRootObject:dataInfo toFile:resumeDataInfoFilePath];
        }
    }
    NSURLSessionDataTask *downloadTask = [self.downloadSession dataTaskWithRequest:downloadRequest];
    return downloadTask;
}

- (void)suspendAllDownloadRequests {
    if (![[MTTNetworkRequestPool sharedPool]remainingCurrentRequests]) {
        return;
    }
    
    __block BOOL hasDownloadRequests = false;
    [[MTTNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        if (requestModel.requestType == MTTRequestTypeDownload) {
            hasDownloadRequests = true;
            if (requestModel.task) {
                if (requestModel.task.state == NSURLSessionTaskStateRunning) {
                    if (requestModel.backgroundDownloadSupport) {
                        requestModel.manualOperation = MTTDownloadManualOperationSuspend;
                        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestModel.task;
                        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        
                        }];
                    } else {
                        [requestModel.task suspend];
                        [_cacheManager updateResumeDataInfoAfterSuspendWithRequestModel:requestModel];
                        NSLog(@"暂停下载:%@",requestModel);
                    }
                } else {
                    NSLog(@"下载任务不能暂停,因为任务没有运行中:%@",requestModel);
                }
            } else {
                NSLog(@"没有找到对应的下载任务");
            }
        }
    }];
    if (!hasDownloadRequests) {
        NSLog(@"没有要暂停的下载任务");
    }
}

- (void)suspendDownloadRequest:(NSString *)url {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务的url不能为空,无法暂停");
        }
        return;
    }
    
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    NSString *downloadRequestIdentifer = [MTTNetworkUtils generateDownloadRequestIdentiferWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url];
    [self pSuspendDownloadRequestWithDownloadRequestIdentifer:downloadRequestIdentifer];
}

- (void)pSuspendDownloadRequestWithDownloadRequestIdentifer:(NSString *)downloadRequestIdentifer {
    [[MTTNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        if ([requestModel.requestIdentifer isEqualToString:downloadRequestIdentifer]) {
            if (requestModel.task) {
                if (requestModel.task) {
                    if (requestModel.task.state == NSURLSessionTaskStateRunning) {
                        if (requestModel.backgroundDownloadSupport) {
                            requestModel.manualOperation = MTTDownloadManualOperationSuspend;
                            NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestModel.task;
                            [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                                
                            }];
                        } else {
                            [requestModel.task suspend];
                            [_cacheManager updateResumeDataInfoAfterSuspendWithRequestModel:requestModel];
                            NSLog(@"暂停下载任务:%@",requestModel);
                        }
                    } else {
                        NSLog(@"b下载任务不能暂停,因为任务没有运行中:%@",requestModel);
                    }
                } else {
                    NSLog(@"b没有找到对应的下载任务");
                }
            }
        }
    }];
}

- (void)suspendDownloadRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务的url不能为空,无法暂停");
        }
        return;
    }
    
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    NSString *baseURL;
    if (!ignoreBaseURL) {
        baseURL = [MTTNetworkConfig sharedConfig].baseUrl;
    }
    
    NSString *downloadRequestIdentifer = [MTTNetworkUtils generateDownloadRequestIdentiferWithBaseURL:baseURL requestURL:url];
    [self pSuspendDownloadRequestWithDownloadRequestIdentifer:downloadRequestIdentifer];
}

- (void)suspendDownloadRequests:(NSArray *)urls {
    if (urls.count == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务url列表为空");
        }
        return;
    }
    
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspendDownloadRequest:url];
    }];
}

- (void)suspendDownloadRequests:(NSArray *)urls ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (urls.count == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务url列表为空");
        }
        return;
    }
    
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self suspendDownloadRequest:url ignoreBaseURL:ignoreBaseURL];
    }];
}

- (void)resumeAllDownloadRequests {
    __block BOOL hasDownloadRequests = false;
    [[MTTNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        if (requestModel.requestType == MTTRequestTypeDownload) {
            hasDownloadRequests = true;
            if (requestModel.task) {
                if (requestModel.backgroundDownloadSupport) {
                    NSString *resumeDataFilePath = requestModel.resumeDataInfoFilePath;
                    if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
                        if (resumeData) {
                            NSString *oldTaskKey = [NSString stringWithFormat:@"%ld",requestModel.task.taskIdentifier];
                            NSURLSessionTask *downloadTask = [self.backgroundDownloadSession downloadTaskWithResumeData:resumeData];
                            requestModel.task = downloadTask;
                            [[MTTNetworkRequestPool sharedPool] changeRequestModel:requestModel forKey:oldTaskKey];
                            [downloadTask resume];
                            NSLog(@"恢复后台下载任务");
                        } else {
                            NSLog(@"不能恢复后台下载任务,因为resumeData为空");
                        }
                    } else {
                        NSLog(@"不能恢复后台下载任务,因为resumeData路径为空");
                    }
                } else {
                    if (requestModel.task.state == NSURLSessionTaskStateSuspended) {
                        [requestModel.task resume];
                        NSLog(@"恢复下载任务成功");
                    } else {
                        NSLog(@"下载任务当前不是暂停状态,不用恢复");
                    }
                }
            } else {
                NSLog(@"当前请求没有下载任务");
            }
        }
    }];
    
    if (!hasDownloadRequests) {
        NSLog(@"当前没有下载任务用于恢复");
    }
}

- (void)resumeDownloadRequest:(NSString *)url {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"待恢复的下载任务url为空");
        }
        return;
    }
    
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    NSString *downloadRequestIdentifer = [MTTNetworkUtils generateDownloadRequestIdentiferWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url];
    [self pResuemDownloadRequestWithDownloadRequestIdentifer:downloadRequestIdentifer];
}

- (void)pResuemDownloadRequestWithDownloadRequestIdentifer:(NSString *)downloadRequestIdentifer {
    [[MTTNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        if ([requestModel.requestIdentifer isEqualToString:downloadRequestIdentifer]) {
            if (requestModel.task) {
                if (requestModel.backgroundDownloadSupport) {
                    if (requestModel.manualOperation == MTTDownloadManualOperationSuspend) {
                        NSString *resumeDataFilePath = requestModel.resumeDataInfoFilePath;
                        if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                            NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
                            if (resumeData) {
                                NSString *oldTaskKey = [NSString stringWithFormat:@"%ld",requestModel.task.taskIdentifier];
                                NSURLSessionTask *downloadTask = [self.backgroundDownloadSession downloadTaskWithResumeData:resumeData];
                                requestModel.manualOperation = MTTDownloadManualOperationResume;
                                requestModel.task = downloadTask;
                                [[MTTNetworkRequestPool sharedPool] changeRequestModel:requestModel forKey:oldTaskKey];
                                [downloadTask resume];
                                NSLog(@"恢复后台下载任务成功:%@",requestModel);
                            } else {
                                NSLog(@"恢复后台下载任务失败,因为没有resumeData");
                            }
                        } else {
                            NSLog(@"恢复后台下载任务失败,因为resumeData路径为空");
                        }
                    } else {
                        NSLog(@"不需要恢复下载任务,因为当前任务不是暂停状态");
                    }
                } else {
                    if (requestModel.task.state == NSURLSessionTaskStateSuspended) {
                        [requestModel.task resume];
                        NSLog(@"恢复正常下载任务成功:%@",requestModel);
                    } else {
                        NSLog(@"恢复正常下载任务失败,因为目前状态不是暂停状态");
                    }
                }
            } else {
                NSLog(@"当前请求没有下载任务");
            }
        }
    }];
}

- (void)resumeDownloadRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"待恢复的下载任务url为空");
        }
        return;
    }
    
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    NSString *baseURL;
    if (!ignoreBaseURL) {
        baseURL = [MTTNetworkConfig sharedConfig].baseUrl;
    }
    NSString *downloadRequestIdentifer = [MTTNetworkUtils generateDownloadRequestIdentiferWithBaseURL:baseURL requestURL:url];
    [self pResuemDownloadRequestWithDownloadRequestIdentifer:downloadRequestIdentifer];
}

- (void)resumeDownloadRequests:(NSArray *)urls {
    if (urls.count == 0) {
        if (_isDebugMode) {
            NSLog(@"要恢复的下载url列表为空");
        }
        return;
    }
    if ([[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self resumeDownloadRequest:url];
    }];
}

- (void)resumeDownloadRequests:(NSArray *)urls ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (urls.count == 0) {
        if (_isDebugMode) {
            NSLog(@"要恢复的下载url列表为空");
        }
        return;
    }
    if ([[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self resumeDownloadRequest:url ignoreBaseURL:ignoreBaseURL];
    }];
}

- (void)cancelAllDownloadRequests {
    if (![[MTTNetworkRequestPool sharedPool] remainingCurrentRequests]) {
        return;
    }
    
    __block BOOL hasDownloadRequests = false;
    [[MTTNetworkRequestPool sharedPool].currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull requestModel, BOOL * _Nonnull stop) {
        if (requestModel.requestType == MTTRequestTypeDownload) {
            hasDownloadRequests = true;
            if (requestModel.task) {
                if (requestModel.backgroundDownloadSupport) {
                    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestModel.task;
                    requestModel.manualOperation = MTTDownloadManualOperationCancel;
                    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        
                    }];
                } else {
                    [requestModel.task cancel];
                }
                NSLog(@"取消下载任务成功");
            } else {
                NSLog(@"当前请求没有对应的下载任务");
            }
        }
    }];
    if (!hasDownloadRequests) {
        NSLog(@"当前没有要取消的下载任务");
    }
}

- (void)cancelDownloadRequest:(NSString *)url {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"要取消的下载任务url不能为空");
        }
        return;
    }
    [[MTTNetworkRequestPool sharedPool] cancelCurrentRequestWithURL:url];
}

- (void)cancelDownloadRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"要取消的下载任务url不能为空");
        }
        return;
    }
    NSString *requestURL;
    if (!ignoreBaseURL) {
        requestURL = [[MTTNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
    } else {
        requestURL = url;
    }
    [[MTTNetworkRequestPool sharedPool] cancelCurrentRequestWithURL:requestURL];
}

- (void)cancelDownloadRequests:(NSArray *)urls {
    if (urls.count == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务对应的url列表为空");
        }
        return;
    }
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        [[MTTNetworkRequestPool sharedPool] cancelCurrentRequestWithURL:url];
    }];
}

- (void)cancelDownloadRequests:(NSArray *)urls ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (urls.count == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务对应的url列表为空");
        }
        return;
    }
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *requestURL;
        if (!ignoreBaseURL) {
            requestURL = [[MTTNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        } else {
            requestURL = url;
        }
        [[MTTNetworkRequestPool sharedPool] cancelCurrentRequestWithURL:requestURL];
    }];
}

- (CGFloat)resumeDataRadioOfRequest:(NSString *)url {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务对应的url列表为空");
        }
        return 0.0;
    }
    NSString *downloadRequestIdentifer = [MTTNetworkUtils generateDownloadRequestIdentiferWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url];
    return [self pResumeDataRatioWithRequestIdentifer:downloadRequestIdentifer];
}

- (CGFloat)pResumeDataRatioWithRequestIdentifer:(NSString *)requestIdentifer {
    NSString *resumeDataInfoFilePath = [MTTNetworkUtils resumeDataInfoFilePathWithRequestIdentifer:requestIdentifer];
    MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:resumeDataInfoFilePath];
    if (dataInfo) {
        return [dataInfo.resumeDataRatio floatValue];
    } else {
        return 0.00;
    }
}

- (CGFloat)resumeDataRadioOfRequest:(NSString *)url ignoreBaseURL:(BOOL)ignoreBaseURL {
    if (url.length == 0) {
        if (_isDebugMode) {
            NSLog(@"下载任务对应的url列表为空");
        }
        return 0.0;
    }
    NSString *baseURL;
    if (!ignoreBaseURL) {
        baseURL = [MTTNetworkConfig sharedConfig].baseUrl;
    }
    NSString *downloadRequestIdentifer = [MTTNetworkUtils generateDownloadRequestIdentiferWithBaseURL:baseURL requestURL:url];
    return [self pResumeDataRatioWithRequestIdentifer:downloadRequestIdentifer];
}

- (void)handleRequestFinished:(MTTNetworkRequestModel *)requestModel {
    [requestModel clearAllBlocks];
    [[MTTNetworkRequestPool sharedPool] removeRequestModel:requestModel];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (_isDebugMode) {
        NSLog(@"下载任务请求已经完成");
    }
    
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",task.taskIdentifier]];
    if (requestModel) {
        if (requestModel.backgroundDownloadSupport) {
            if (error) {
                if (error.code == -999) {
                    [requestModel.task suspend];
                    NSData *resumeData = requestModel.task.error.userInfo[NSURLSessionDownloadTaskResumeData];
                    NSError *moveDownloadFileError;
                    if (requestModel.resumableDownload) {
                        [resumeData writeToFile:requestModel.resumeDataFilePath options:NSDataWritingAtomic error:&moveDownloadFileError];
                    } else {
                        if (requestModel.manualOperation == MTTDownloadManualOperationSuspend) {
                            [resumeData writeToFile:requestModel.resumeDataFilePath options:NSDataWritingAtomic error:&moveDownloadFileError];
                        } else {
                            if (_isDebugMode) {
                                NSLog(@"当前下载任务没有resumeData;");
                            }
                            [_cacheManager removeResumeDataAndResumeDataInfoFileWithRequestModel:requestModel];
                        }
                    }
                    
                    if (requestModel.manualOperation == MTTDownloadManualOperationSuspend) {
                        NSLog(@"暂停后台下载任务:%@",requestModel);
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestModel.downloadFailureBlock) {
                                requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                            }
                            [self handleRequestFinished:requestModel];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (requestModel.downloadFailureBlock) {
                            requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                        }
                        [self handleRequestFinished:requestModel];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (requestModel.downloadFailureBlock) {
                        requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                    }
                    [self handleRequestFinished:requestModel];
                });
            }
        } else {
            if (error) {
                if (error.code == -997) {
                    MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
                    NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:requestModel.resumeDataFilePath error:nil];
                    NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
                    dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",resumeDataLength];
                    
                    CGFloat ratio = 1.0 * [dataInfo.resumeDataLength integerValue] / [dataInfo.totalDataLength integerValue];
                    dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
                    [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
                    
                    [requestModel.stream close];
                    requestModel.stream = nil;
                    
                    NSString *oldTaskKey = [NSString stringWithFormat:@"%ld",requestModel.task.taskIdentifier];
                    NSURLSessionTask *downloadTask = [self pNoneBackgroundDownloadTaskWithRequestModel:requestModel];
                    requestModel.task = downloadTask;
                    [[MTTNetworkRequestPool sharedPool]changeRequestModel:requestModel forKey:oldTaskKey];
                    [requestModel.task resume];
                } else {
                    if (requestModel.resumableDownload) {
                        MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
                        NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:requestModel.resumeDataFilePath error:nil];
                        NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
                        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",resumeDataLength];
                        
                        CGFloat ratio = 1.0 * [dataInfo.resumeDataLength integerValue] / [dataInfo.totalDataLength integerValue];
                        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
                        [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
                        if (_isDebugMode) {
                            NSLog(@"保存下载数据在路径:%@",requestModel.resumeDataFilePath);
                        }
                    } else {
                        if (_isDebugMode) {
                            NSLog(@"移除下载数据在路径:%@",requestModel.resumeDataFilePath);
                        }
                        [_cacheManager removeResumeDataAndResumeDataInfoFileWithRequestModel:requestModel];
                    }
                    
                    [requestModel.stream close];
                    requestModel.stream = nil;
                    NSLog(@"下载失败,文件路径:%@",requestModel.downloadFilePath);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (requestModel.downloadFailureBlock) {
                            requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                        }
                        [self handleRequestFinished:requestModel];
                    });
                }
            } else {
                [_cacheManager removeCompletionDownloadDataAndClearResumeDataInfoFileWithRequestModel:requestModel];
                [requestModel.stream close];
                requestModel.stream = nil;
                NSLog(@"下载失败,文件路径:%@",requestModel.downloadFilePath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (requestModel.downloadFailureBlock) {
                        requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                    }
                    [self handleRequestFinished:requestModel];
                });
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (_isDebugMode) {
        NSLog(@"接收到响应数据:%@",response);
    }
    
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",dataTask.taskIdentifier]];
    if (requestModel) {
        NSInteger statusCode = 0;
        if ([dataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)dataTask.response statusCode];
        }
        
        NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
        NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
        
        if (statusCode > 400) {
            NSError *error = [NSError errorWithDomain:@"request error" code:statusCode userInfo:nil];
            [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
            if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (requestModel.downloadFailureBlock) {
                    requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                }
                [self handleRequestFinished:requestModel];
            });
            return;
        }
        
        [requestModel.stream open];
        MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
        if (!dataInfo) {
            dataInfo = [[MTTNetworkDownloadResumeDataInfo alloc]init];
        }
        
        NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:resumeDataFilePath error:nil];
        NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",resumeDataLength];
        
        NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + [dataInfo.resumeDataLength integerValue];
        dataInfo.totalDataLength = [NSString stringWithFormat:@"%ld",totalLength];
        requestModel.totalLength = totalLength;
        
        CGFloat ratio = 1.0 * [dataInfo.resumeDataLength integerValue] / [dataInfo.totalDataLength integerValue];
        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
        [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(nonnull NSURLSessionDataTask *)dataTask
    didReceiveData:(nonnull NSData *)data {
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",dataTask.taskIdentifier]];
    if (requestModel) {
        [requestModel.stream write:data.bytes maxLength:data.length];
        
        MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
        NSDictionary *attributeDict = [_fileManager attributesOfItemAtPath:requestModel.resumeDataFilePath error:nil];
        NSInteger resumeDataLength = [attributeDict[NSFileSize] integerValue];
        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%ld",resumeDataLength];
        CGFloat ratio = 1.0 * [dataInfo.resumeDataLength integerValue] / [dataInfo.totalDataLength integerValue];
        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
        [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
        if (_isDebugMode) {
            NSLog(@"当前任务下载比例:%@",dataInfo.resumeDataRatio);
        }
        if (requestModel.downloadProgressBlock) {
            requestModel.downloadProgressBlock([dataInfo.resumeDataLength integerValue], requestModel.totalLength, ratio);
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",downloadTask.taskIdentifier]];
    if (requestModel) {
        NSInteger statusCode = 0;
        if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)downloadTask.response statusCode];
        }
        NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
        NSString *resumeDataFilePath = requestModel.resumeDataFilePath;
        if (statusCode > 400) {
            NSError *error;
            if (statusCode == 416) {
                error = [NSError errorWithDomain:@"Range error" code:statusCode userInfo:nil];
            }
            [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
            if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (requestModel.downloadFailureBlock) {
                    requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                }
                [self handleRequestFinished:requestModel];
            });
        } else {
            NSData *tmpDownloadFileData = [NSData dataWithContentsOfURL:location];
            NSUInteger downloadDataLength = tmpDownloadFileData.length;
            NSError *moveDownloadFileError = nil;
            [_fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:requestModel.downloadFilePath] error:&moveDownloadFileError];
            [_fileManager removeItemAtPath:resumeDataInfoFilePath error:nil];
            
            if ([_fileManager fileExistsAtPath:resumeDataFilePath]) {
                [_fileManager removeItemAtPath:resumeDataFilePath error:nil];
            }
            if (moveDownloadFileError && moveDownloadFileError.code != 516) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (requestModel.downloadFailureBlock) {
                        requestModel.downloadFailureBlock(requestModel.task, moveDownloadFileError, nil);
                    }
                    [self handleRequestFinished:requestModel];
                });
            } else {
                if (requestModel.downloadProgressBlock) {
                    requestModel.downloadProgressBlock(downloadDataLength, downloadDataLength, 1);
                }
                if (moveDownloadFileError.code == 516) {
                    [_fileManager removeItemAtPath:location.absoluteString error:nil];
                }
                
                NSLog(@"任务下载成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (requestModel.downloadSuccessBlock) {
                        requestModel.downloadSuccessBlock(requestModel.downloadFilePath);
                    }
                    [self handleRequestFinished:requestModel];
                });
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestPool sharedPool].currentRequestModels objectForKey:[NSString stringWithFormat:@"%ld",downloadTask.taskIdentifier]];
    if (requestModel) {
        if (!requestModel.totalLength) {
            requestModel.totalLength = (NSInteger)totalBytesExpectedToWrite;
        }
        
        CGFloat ratio = 1.0 * totalBytesWritten / requestModel.totalLength;
        NSString *resumeDataInfoFilePath = requestModel.resumeDataInfoFilePath;
        MTTNetworkDownloadResumeDataInfo *dataInfo = [_cacheManager loadResumeDataInfo:resumeDataInfoFilePath];
        dataInfo.resumeDataLength = [NSString stringWithFormat:@"%lld",totalBytesWritten];
        dataInfo.totalDataLength = [NSString stringWithFormat:@"%ld",requestModel.totalLength];
        dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",ratio];
        [NSKeyedArchiver archiveRootObject:dataInfo toFile:resumeDataInfoFilePath];
        if (_isDebugMode) {
            NSLog(@"任务下载比例:%@",dataInfo.resumeDataRatio);
        }
        if (requestModel.downloadProgressBlock) {
            requestModel.downloadProgressBlock((NSInteger)bytesWritten, requestModel.totalLength, ratio);
        }
    }
}

@end
