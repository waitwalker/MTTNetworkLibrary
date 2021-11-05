//
//  MTTNetworkRequestPool.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/1.
//

#import "MTTNetworkRequestPool.h"
#import "MTTNetworkUtils.h"
#import "MTTNetworkConfig.h"
#import "MTTNetworkRequestModel.h"
#import "MTTNetworkProtocol.h"

#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import <pthread/pthread.h>

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

static char currentRequestModelsKey;

@interface MTTNetworkRequestPool ()<MTTNetworkProtocol>


@end

@implementation MTTNetworkRequestPool{
    pthread_mutex_t _lock;
    BOOL _isDebugMode;
}

+ (instancetype)sharedPool {
    static MTTNetworkRequestPool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MTTNetworkRequestPool alloc]init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _isDebugMode = [MTTNetworkConfig sharedConfig].debugMode;
    }
    return self;
}

- (MTTCurrentRequestModels *)currentRequestModels {
    MTTCurrentRequestModels *currentTasks = objc_getAssociatedObject(self, &currentRequestModelsKey);
    if (!currentTasks) {
        currentTasks = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &currentRequestModelsKey, currentTasks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return currentTasks;
}

- (void)addRequestModel:(MTTNetworkRequestModel *)requestModel {
    Lock();
    [self.currentRequestModels setObject:requestModel forKey:[NSString stringWithFormat:@"%ld",(unsigned long)requestModel.task.taskIdentifier]];
    Unlock();
}

- (void)removeRequestModel:(MTTNetworkRequestModel *)requestModel {
    Lock();
    [self.currentRequestModels removeObjectForKey:[NSString stringWithFormat:@"%ld",requestModel.task.taskIdentifier]];
    Unlock();
}

- (void)changeRequestModel:(MTTNetworkRequestModel *)requestModel forKey:(NSString *)key {
    Lock();
    [self.currentRequestModels removeObjectForKey:key];
    [self.currentRequestModels setObject:requestModel forKey:[NSString stringWithFormat:@"%ld",requestModel.task.taskIdentifier]];
    Unlock();
}

- (BOOL)remainingCurrentRequests {
    NSArray *keys = [self.currentRequestModels allKeys];
    if (keys.count > 0) {
        NSLog(@"请求池里还有剩余的请求");
        return true;
    }
    NSLog(@"请求池里面没有请求了");
    return false;
}

- (NSInteger)currentRequestCount {
    NSLog(@"当前请求池中请求还有的请求数量:%lu",(unsigned long)self.currentRequestModels.count);
    return self.currentRequestModels.count;
}

- (void)printAllCurrentRequests {
    if ([self remainingCurrentRequests]) {
        [self.currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"请求池中的当前请求:%@",obj);
        }];
    }
}

- (void)cancelAllCurrentRequests {
    if ([self remainingCurrentRequests]) {
        for (MTTNetworkRequestModel *requestModel in [self.currentRequestModels allValues]) {
            if (requestModel.requestType == MTTRequestTypeDownload) {
                if (requestModel.backgroundDownloadSupport) {
                    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestModel.task;
                    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        
                    }];
                } else {
                    [requestModel.task cancel];
                }
            } else {
                [requestModel.task cancel];
                [self removeRequestModel:requestModel];
            }
        }
        NSLog(@"请求池中所有的请求都清空了");
    }
}

- (void)cancelCurrentRequestWithURL:(NSString *)url {
    if ([self remainingCurrentRequests]) {
        return;
    }
    
    NSMutableArray *cancelRequestModelsArr = [NSMutableArray arrayWithCapacity:2];
    NSString *requestIdentiferOfURL = [MTTNetworkUtils generateMD5StringFromString:[NSString stringWithFormat:@"Url:%@",url]];
    [self.currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.requestIdentifer containsString:requestIdentiferOfURL]) {
            [cancelRequestModelsArr addObject:obj];
        }
    }];
    
    if (cancelRequestModelsArr.count == 0) {
        NSLog(@"请求池里面没有要取消的请求");
    } else {
        if (_isDebugMode) {
            [cancelRequestModelsArr enumerateObjectsUsingBlock:^(MTTNetworkRequestModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"要取消请求的url:%@",obj.requestUrl);
            }];
        }
        
        [cancelRequestModelsArr enumerateObjectsUsingBlock:^(MTTNetworkRequestModel  *requestModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (requestModel.requestType == MTTRequestTypeDownload) {
                if (requestModel.backgroundDownloadSupport) {
                    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestModel.task;
                    if (requestModel.task.state == NSURLSessionTaskStateCompleted) {
                        NSLog(@"支持后台下载的请求:%@",requestModel);
                        NSError *error = [NSError errorWithDomain:@"Request has been canceled" code:0 userInfo:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (requestModel.downloadFailureBlock) {
                                requestModel.downloadFailureBlock(requestModel.task, error, requestModel.resumeDataFilePath);
                            }
                            [self handleRequestFinished:requestModel];
                        });
                    } else {
                        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                                                    
                        }];
                        NSLog(@"支持后台下载的请求已经被取消:%@",requestModel);
                    }
                } else {
                    [requestModel.task cancel];
                    NSLog(@"1请求已经被取消:%@",requestModel);
                }
            } else {
                [requestModel.task cancel];
                NSLog(@"2请求已经被取消:%@",requestModel);
                if (requestModel.requestType != MTTRequestTypeDownload) {
                    [self removeRequestModel:requestModel];
                }
            }
        }];
        NSLog(@"url:%@相关的请求都取消了",url);
    }
}

- (void)cancelCurrentRequestWithURLS:(NSArray *)urls {
    if (urls.count == 0) {
        NSLog(@"urls不能为空");
        return;
    }
    
    if (![self remainingCurrentRequests]) {
        NSLog(@"请求池已经为空了");
        return;
    }
    [urls enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelCurrentRequestWithURL:obj];
    }];
}

- (void)cancelCurrentRequestWithURL:(NSString *)url method:(NSString *)method parameters:(id)parameters {
    if (![self remainingCurrentRequests]) {
        return;
    }
    NSString *requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:method parameters:parameters];
    [self pCancelRequestWithRequestIdentifer:requestIdentifer];
}

- (void)pCancelRequestWithRequestIdentifer:(NSString *)requestIdentifer {
    [self.currentRequestModels enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MTTNetworkRequestModel * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([requestIdentifer isEqualToString:obj.requestIdentifer]) {
            if (obj.task) {
                [obj.task cancel];
                if (obj.requestType != MTTRequestTypeDownload) {
                    [self removeRequestModel:obj];
                }
            } else {
                NSLog(@"当前请求没有对应的task");
            }
        }
    }];
}

- (void)handleRequestFinished:(MTTNetworkRequestModel *)requestModel {
    [requestModel clearAllBlocks];
    [[MTTNetworkRequestPool sharedPool]removeRequestModel:requestModel];
}


@end
