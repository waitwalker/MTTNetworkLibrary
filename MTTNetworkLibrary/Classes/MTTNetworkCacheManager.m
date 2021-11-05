//
//  MTTNetworkCacheManager.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/29.
//

#import "MTTNetworkCacheManager.h"
#import "MTTNetworkUtils.h"
#import "MTTNetworkConfig.h"
#import "MTTNetworkCacheInfo.h"

@interface MTTNetworkCacheManager ()
{
    dispatch_queue_t _cache_io_queue;
    NSFileManager *_fileManager;
    NSString *_cacheBasePath;
    BOOL _isDebugMode;
}


@end

@implementation MTTNetworkCacheManager

+ (instancetype)sharedInstance {
    static MTTNetworkCacheManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[MTTNetworkCacheManager alloc]init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _cache_io_queue = dispatch_queue_create("cn.waitwalker.io", DISPATCH_QUEUE_SERIAL);
        _fileManager = [NSFileManager defaultManager];
        _cacheBasePath = [MTTNetworkUtils createCacheBasePath];
        _isDebugMode = [MTTNetworkConfig sharedConfig].debugMode;
    }
    return self;
}

- (void)writeCacheWithRequestModel:(MTTNetworkRequestModel *)requestModel asynchrously:(BOOL)asynchronously {
    if (asynchronously) {
        dispatch_async(_cache_io_queue, ^{
            [self pWriteCacheWithRequestModel:requestModel];
        });
    } else {
        [self pWriteCacheWithRequestModel:requestModel];
    }
}

- (void)pWriteCacheWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    if (requestModel.response) {
        [requestModel.responseData writeToFile:requestModel.cacheDataFilePath atomically:true];
        MTTNetworkCacheInfo *cacheInfo = [MTTNetworkCacheInfo new];
        cacheInfo.createDate = [NSDate date];
        cacheInfo.cacheDuration = [NSNumber numberWithInteger:requestModel.cacheDuration];
        cacheInfo.appVersion = [MTTNetworkUtils appVersion];
        cacheInfo.requestIdentifer = requestModel.requestIdentifer;
        
        [NSKeyedArchiver archiveRootObject:cacheInfo toFile:requestModel.cacheDataInfoFilePath];
        if (_isDebugMode) {
            NSLog(@"======写入缓存数据成功======\ncache object:%@\n,cache path:%@\n,available duration:%@",requestModel.responseObject,requestModel.cacheDataFilePath,cacheInfo.cacheDuration);
        }
    } else {
        if (_isDebugMode) {
            NSLog(@"写入缓存数据失败");
        }
    }
}

- (void)loadCacheWithURL:(NSString *)url completionBlock:(MTTLoadCacheArrayCompletionBlock)completionBlock {
    NSString *identifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:nil];
    [self pLoadCacheWithPartialIdentifer:identifer completionBlock:completionBlock];
}

- (void)loadCacheWithURL:(NSString *)url method:(NSString *)method completionBlock:(MTTLoadCacheArrayCompletionBlock)completionBlock {
    NSString *requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:method];
    [self pLoadCacheWithPartialIdentifer:requestIdentifer completionBlock:completionBlock];
}

- (void)loadCacheWithURL:(NSString *)url method:(NSString *)method parameters:(id)parameters completionBlock:(MTTLoadCacheCompletionBlock)completionBlock {
    NSString *requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:method parameters:parameters];
    [self loadCacheWithRequestIdentifer:requestIdentifer completionBlock:^(NSArray * _Nullable cacheObject) {
        if (completionBlock) {
            completionBlock(cacheObject);
        }
    }];
}

- (void)pLoadCacheWithPartialIdentifer:(NSString *)identifer completionBlock:(MTTLoadCacheArrayCompletionBlock)completionBlock {
    NSDirectoryEnumerator *enumerator = [_fileManager enumeratorAtPath:_cacheBasePath];
    NSMutableArray *requestIdentiferArr = [[NSMutableArray alloc]initWithCapacity:2];
    for (NSString *fileName in enumerator) {
        if ([fileName containsString:identifer]) {
            if ([fileName containsString:kNetworkCacheFileSuffix]) {
                NSString *identiferTmp = [fileName substringWithRange:NSMakeRange(0, (fileName.length - kNetworkCacheFileSuffix.length - 1))];
                [requestIdentiferArr addObject:identiferTmp];
            }
        }
    }
    
    if (requestIdentiferArr.count > 0) {
        NSMutableArray *cacheObjArr = [[NSMutableArray alloc]initWithCapacity:2];
        for (NSString *requestIdentifer in requestIdentiferArr) {
            [self loadCacheWithRequestIdentifer:requestIdentifer completionBlock:^(id  _Nullable cacheObject) {
                if (cacheObject) {
                    [cacheObjArr addObject:cacheObject];
                }
            }];
        }
        
        if (_isDebugMode) {
            NSLog(@"加载缓存成功,找到url相关缓存");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock([cacheObjArr copy]);
            }
        });
    } else {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,没有找到url相关缓存");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }
}


- (void)loadCacheWithRequestIdentifer:(NSString *)requestIdentifer completionBlock:(MTTLoadCacheCompletionBlock)completionBlock {
    NSString *cacheDataFilePath = [MTTNetworkUtils cacheDataFilePathWithRequestIdentifer:requestIdentifer];
    NSString *cacheInfoFilePath = [MTTNetworkUtils cacheDataInfoFilePathWithRequestIdentifer:requestIdentifer];
    MTTNetworkCacheInfo *cacheInfo = [self pLoadCacheInfoWithRequestIdentifer:requestIdentifer];
    if (!cacheInfo) {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,缓存info文件不存在");
        }
        [self pRemoveCacheDataFile:cacheDataFilePath cacheInfoFile:cacheInfoFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        return;
    }
    
    BOOL cacheValidation = [self pCheckCacheValidation:cacheInfo];
    if (!cacheValidation) {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,缓存信息无效");
        }
        [self pRemoveCacheDataFile:cacheDataFilePath cacheInfoFile:cacheInfoFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        return;
    }
    
    id cacheObj = [self pLoadCacheObjectWithCacheFilePath:cacheDataFilePath];
    if (!cacheObj) {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,缓存数据不存在");
        }
        [self pRemoveCacheDataFile:cacheDataFilePath cacheInfoFile:cacheInfoFilePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
        return;
    } else {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,缓存路径:%@",cacheDataFilePath);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }
}

- (MTTNetworkCacheInfo *)pLoadCacheInfoWithRequestIdentifer:(NSString *)requestIdentifer {
    NSString *cacheInfoFilePath = [MTTNetworkUtils cacheDataInfoFilePathWithRequestIdentifer:requestIdentifer];
    MTTNetworkCacheInfo *cacheInfo;
    if ([_fileManager fileExistsAtPath:cacheInfoFilePath isDirectory:nil]) {
        cacheInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheInfoFilePath];
        if ([cacheInfo isKindOfClass:[MTTNetworkCacheInfo class]]) {
            return cacheInfo;
        } else {
            return nil;
        }
    }
    return nil;
}

- (void)pRemoveCacheDataFile:(NSString *)cacheDataFilePath cacheInfoFile:(NSString *)cacheInfoFilePath {
    if ([_fileManager fileExistsAtPath:cacheDataFilePath]) {
        [_fileManager removeItemAtPath:cacheDataFilePath error:nil];
    }
    
    if ([_fileManager fileExistsAtPath:cacheInfoFilePath]) {
        [_fileManager removeItemAtPath:cacheInfoFilePath error:nil];
    }
}

- (BOOL)pCheckCacheValidation:(MTTNetworkCacheInfo *)cacheInfo {
    if (!cacheInfo || ![cacheInfo isKindOfClass:[MTTNetworkCacheInfo class]]) {
        return false;
    }
    
    NSDate *creationDate = cacheInfo.createDate;
    NSTimeInterval pastDuration = [creationDate timeIntervalSinceNow];
    NSTimeInterval cacheDuration = [cacheInfo.cacheDuration integerValue];
    if (cacheDuration <= 0) {
        if (_isDebugMode) {
            NSLog(@"加载缓存info失败,没有设置缓存时间");
        }
        [self pClearCacheWithIdentifer:cacheInfo.requestIdentifer completionBlock:nil];
        return false;
    }
    
    if (pastDuration < 0 || pastDuration > cacheDuration) {
        if (_isDebugMode) {
            NSLog(@"缓存加载失败,缓存时间超过设定时间");
        }
        [self pClearCacheWithIdentifer:cacheInfo.requestIdentifer completionBlock:nil];
        return false;
    }
    
    NSString *cacheAppVersion = cacheInfo.appVersion;
    NSString *currentAppVersion = [MTTNetworkUtils appVersion];
    if (!cacheAppVersion && !currentAppVersion) {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,缓存appVersion && 当前APPVersion都不存在");
        }
        [self pClearCacheWithIdentifer:cacheInfo.requestIdentifer completionBlock:nil];
        return false;
    }
    
    if (cacheAppVersion.length != currentAppVersion.length || ![cacheAppVersion isEqualToString:currentAppVersion]) {
        if (_isDebugMode) {
            NSLog(@"加载缓存失败,缓存appVersion && 当前APPVersion信息不匹配");
        }
        [self pClearCacheWithIdentifer:cacheInfo.requestIdentifer completionBlock:nil];
        return false;
    }
    return true;
}

- (void)pClearCacheWithIdentifer:(NSString *)identifer completionBlock:(MTTClearCacheCompletionBlock _Nullable)completionBlock {
    NSMutableArray *deleteFileNamesArr = [[NSMutableArray alloc]initWithCapacity:2];
    NSDirectoryEnumerator *enumerator = [_fileManager enumeratorAtPath:_cacheBasePath];
    
    for (NSString *fileName in enumerator) {
        if ([fileName containsString:identifer]) {
            NSString *deleteFilePath = [_cacheBasePath stringByAppendingPathComponent:fileName];
            [deleteFileNamesArr addObject:deleteFilePath];
        }
    }
    
    if (deleteFileNamesArr.count > 0) {
        for (NSInteger index = 0; index < deleteFileNamesArr.count; index ++) {
            dispatch_async(_cache_io_queue, ^{
                [self->_fileManager removeItemAtPath:deleteFileNamesArr[index] error:nil];
                if (index == deleteFileNamesArr.count - 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self->_isDebugMode) {
                            NSLog(@"清空缓存成功");
                        }
                        if (completionBlock) {
                            completionBlock(nil);
                            return;
                        }
                    });
                }
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_isDebugMode) {
                NSLog(@"清空缓存失败,没有相关的缓存信息");
            }
            if (completionBlock) {
                completionBlock(nil);
                return;
            }
        });
    }
}

- (id)pLoadCacheObjectWithCacheFilePath:(NSString *)cacheFilePath {
    id cacheObj;
    NSError *error;
    if ([_fileManager fileExistsAtPath:cacheFilePath isDirectory:nil]) {
        NSData *data = [NSData dataWithContentsOfFile:cacheFilePath];
        cacheObj = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error];
        if (cacheObj) {
            return cacheObj;
        }
    }
    return cacheObj;
}

- (void)calculateAllCacheSize:(MTTCalculateSizeCompletionBlock)completionBlock {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:_cacheBasePath isDirectory:true];
    dispatch_async(_cache_io_queue, ^{
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        NSDirectoryEnumerator *fileEnumerator = [self->_fileManager enumeratorAtURL:diskCacheURL includingPropertiesForKeys:@[NSFileSize] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += fileSize.unsignedIntegerValue;
            fileCount += 1;
        }
        
        NSString *totalSizeStr;
        NSUInteger mb = 1024 * 1024;
        if (totalSize < mb) {
            totalSizeStr = [NSString stringWithFormat:@"%.4f KB",(totalSize * 1.0 / 1024)];
        } else {
            totalSizeStr = [NSString stringWithFormat:@"%.4f MB",(totalSize * 1.0 / mb)];
        }
        
        if (self->_isDebugMode) {
            NSLog(@"甲酸缓存大小成功");
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize, totalSizeStr);
            });
        }
    });
}

- (void)clearAllCache:(MTTClearCacheCompletionBlock)completionBlock {
    dispatch_async(_cache_io_queue, ^{
        NSError *removeCacheFolderError;
        NSError *createCacheFolderError;
        [self->_fileManager removeItemAtPath:self->_cacheBasePath error:&removeCacheFolderError];
        if (!removeCacheFolderError) {
            [self->_fileManager createDirectoryAtPath:self->_cacheBasePath withIntermediateDirectories:true attributes:nil error:&createCacheFolderError];
            if (!createCacheFolderError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"清除所有缓存成功");
                    if (completionBlock) {
                        completionBlock(true);
                        return;
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"清除所有缓存失败,创建缓存目录失败");
                    if (completionBlock) {
                        completionBlock(false);
                        return;
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"清除所有缓存失败,移除缓存目录失败");
                if (completionBlock) {
                    completionBlock(false);
                    return;
                }
            });
        }
        
    });
}

- (void)clearCacheWithURL:(NSString *)url completionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    NSString *identifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:nil];
    [self pClearCacheWithIdentifer:identifer completionBlock:completionBlock];
}

- (void)clearCacheWithURL:(NSString *)url method:(NSString *)method completionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    NSString *identifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:method];
    [self pClearCacheWithIdentifer:identifer completionBlock:completionBlock];
}

- (void)clearCacheWithURL:(NSString *)url method:(NSString *)method parameters:(id)parameters completionBlock:(MTTClearCacheCompletionBlock)completionBlock {
    NSString *identifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:method parameters:parameters];
    [self pClearCacheWithIdentifer:identifer completionBlock:completionBlock];
}

- (void)updateResumeDataInfoAfterSuspendWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    NSData *resumeData = requestModel.task.error.userInfo[NSURLSessionDownloadTaskResumeData];
    [resumeData writeToFile:requestModel.resumeDataFilePath options:NSDataWritingAtomic error:nil];
    
    int64_t downloadByte = requestModel.task.countOfBytesReceived;
    int64_t totalByte = requestModel.task.countOfBytesExpectedToReceive;
    CGFloat percent = 1.0 * downloadByte / totalByte;
    MTTNetworkDownloadResumeDataInfo *dataInfo = [self loadResumeDataInfo:requestModel.resumeDataInfoFilePath];
    dataInfo.resumeDataLength = [NSString stringWithFormat:@"%lld",downloadByte];
    dataInfo.totalDataLength = [NSString stringWithFormat:@"%lld",totalByte];
    dataInfo.resumeDataRatio = [NSString stringWithFormat:@"%.2f",percent];
    [NSKeyedArchiver archiveRootObject:dataInfo toFile:requestModel.resumeDataInfoFilePath];
}

- (void)removeResumeDataAndResumeDataInfoFileWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    [_fileManager removeItemAtPath:requestModel.resumeDataFilePath error:nil];
    [_fileManager removeItemAtPath:requestModel.resumeDataInfoFilePath error:nil];
}

- (void)removeCompletionDownloadDataAndClearResumeDataInfoFileWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    NSError *moveFileError;
    [_fileManager moveItemAtPath:requestModel.resumeDataFilePath toPath:requestModel.downloadFilePath error:&moveFileError];
    if (moveFileError.code == 516) {
        [_fileManager removeItemAtPath:requestModel.resumeDataFilePath error:nil];
    }
    
    [_fileManager removeItemAtPath:requestModel.resumeDataInfoFilePath error:nil];
}

- (MTTNetworkDownloadResumeDataInfo *)loadResumeDataInfo:(NSString *)filePath {
    MTTNetworkDownloadResumeDataInfo *dataInfo;
    if ([_fileManager fileExistsAtPath:filePath isDirectory:nil]) {
        dataInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if ([dataInfo isKindOfClass:[MTTNetworkDownloadResumeDataInfo class]]) {
            return dataInfo;
        }
    }
    return nil;
}

@end
