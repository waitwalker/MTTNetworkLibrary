//
//  MTTNetworkRequestEngine.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/2.
//

#import "MTTNetworkRequestEngine.h"
#import "MTTNetworkCacheManager.h"
#import "MTTNetworkRequestPool.h"
#import "MTTNetworkConfig.h"
#import "MTTNetworkUtils.h"
#import "MTTNetworkProtocol.h"

@interface MTTNetworkRequestEngine ()<MTTNetworkProtocol>

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) MTTNetworkCacheManager *cacheManager;

@end

@implementation MTTNetworkRequestEngine{
    NSFileManager *_fileManager;
    BOOL _isDebugMode;
}

- (instancetype)init {
    if (self = [super init]) {
        _fileManager = [NSFileManager defaultManager];
        _cacheManager = [MTTNetworkCacheManager sharedInstance];
        _isDebugMode = [MTTNetworkConfig sharedConfig].debugMode;
        _sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.allowsCellularAccess = true;
        _sessionManager.requestSerializer.timeoutInterval = [MTTNetworkConfig sharedConfig].timeoutSeconds;
        
        _sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        _sessionManager.securityPolicy.allowInvalidCertificates = true;
        _sessionManager.securityPolicy.validatesDomainName = false;
        
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [[NSSet alloc]initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
        
        _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

- (void)fetchRequest:(NSString *)url
              method:(MTTRequestMethod)method
          parameters:(id)parameters
           loadCache:(BOOL)loadCache
       cacheDuration:(NSTimeInterval)cacheDuration
             success:(MTTSuccessBlock)successBlock
             failure:(MTTFailureBlock)failureBlock {
    NSString *fullURLStr = [MTTNetworkUtils generateFullURLWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl andRequestURL:url];
    
    NSString *methodStr = [self pMethodStringFromRequestMethod:method];
    
    NSString *requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:methodStr parameters:parameters];
    if (loadCache) {
        [_cacheManager loadCacheWithRequestIdentifer:requestIdentifer completionBlock:^(id  _Nullable cacheObject) {
            if (cacheObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self->_isDebugMode) {
                        NSLog(@"通过加载缓存的请求成功,url:%@,response:%@",fullURLStr,cacheObject);
                    }
                    
                    if (successBlock) {
                        successBlock(cacheObject);
                        return;
                    }
                });
            } else {
                NSLog(@"不加载缓存直接发起请求,发起新的请求");
                [self pFetchRequestWithFullURLString:fullURLStr
                                              method:methodStr
                                          parameters:parameters
                                           loadCache:loadCache
                                       cacheDuration:cacheDuration
                                    requestIdentifer:requestIdentifer
                                             success:successBlock
                                             failure:failureBlock];
            }
        }];
    } else {
        NSLog(@"不加载缓存直接发起请求,发起新的请求");
        [self pFetchRequestWithFullURLString:fullURLStr
                                      method:methodStr
                                  parameters:parameters
                                   loadCache:loadCache
                               cacheDuration:cacheDuration
                            requestIdentifer:requestIdentifer
                                     success:successBlock
                                     failure:failureBlock];
    }
    
}

- (NSString *)pMethodStringFromRequestMethod:(MTTRequestMethod)method {
    switch (method) {
        case MTTRequestMethodGet:
            return @"GET";
            break;
        case MTTRequestMethodPost:
            return @"POST";
            break;
        case MTTRequestMethodPut:
            return @"PUT";
            break;
        case MTTRequestMethodDelete:
            return @"DELETE";
            break;
    }
}

- (void)pFetchRequestWithFullURLString:(NSString *)fullURLString
                                method:(NSString *)method
                            parameters:(id)parameters
                             loadCache:(BOOL)loadCache
                         cacheDuration:(NSTimeInterval)cacheDuration
                      requestIdentifer:(NSString *)requestIdentifer
                               success:(MTTSuccessBlock)successBlock
                               failure:(MTTFailureBlock)failureBlock {
    [self addCustomHeaders];
    
    NSDictionary *fullParameters = [self addDefaultParameterWithCustomParameters:parameters];
    
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestModel alloc]init];
    requestModel.requestUrl = fullURLString;
    requestModel.method = method;
    requestModel.parameters = fullParameters;
    requestModel.loadCache = loadCache;
    requestModel.cacheDuration = cacheDuration;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.successBlock = successBlock;
    requestModel.failureBlock = failureBlock;
    
    NSError *__autoreleasing requestSerializationError = nil;
    NSURLSessionDataTask *dataTask = [self pDataTaskWithRequestModel:requestModel requestSerializer:_sessionManager.requestSerializer error:&requestSerializationError];
    requestModel.task = dataTask;
    [[MTTNetworkRequestPool sharedPool] addRequestModel:requestModel];
    if (_isDebugMode) {
        NSLog(@"开始请求:fullURL:%@ method:%@ parameter:%@",fullURLString,method,fullParameters);
    }
    [dataTask resume];
}

- (void)addCustomHeaders {
    NSDictionary *customHeaders = [MTTNetworkConfig sharedConfig].customHeaders;
    if (customHeaders.count > 0) {
        [customHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString *obj, BOOL * _Nonnull stop) {
            [_sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
            if (_isDebugMode) {
                NSLog(@"添加请求头key:%@ value:%@",key,obj);
            }
        }];
    }
}

- (id)addDefaultParameterWithCustomParameters:(id)parameters {
    id parameterSpliced;
    if (parameters && [parameters isKindOfClass:[NSDictionary class]]) {
        if ([MTTNetworkConfig sharedConfig].defaultParameters.allKeys.count > 0) {
            NSMutableDictionary *defaultParametersM = [[MTTNetworkConfig sharedConfig].defaultParameters mutableCopy];
            [defaultParametersM addEntriesFromDictionary:parameters];
            parameterSpliced = [defaultParametersM copy];
        } else {
            parameterSpliced = parameters;
        }
    } else {
        parameterSpliced = [MTTNetworkConfig sharedConfig].defaultParameters;
    }
    return parameterSpliced;
}

- (NSURLSessionDataTask *)pDataTaskWithRequestModel:(MTTNetworkRequestModel *)requestModel
                                  requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                              error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:requestModel.method URLString:requestModel.requestUrl parameters:requestModel.parameters error:error];
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [_sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [weakSelf pHandleRequestModel:requestModel responseObject:responseObject error:error];
    }];
    return dataTask;
}

- (void)pHandleRequestModel:(MTTNetworkRequestModel *)requestModel
             responseObject:(id)responseObject
                      error:(NSError *)error {
    NSError *requestError = nil;
    BOOL requestSuccess = true;
    if (error) {
        requestSuccess = false;
        requestError = error;
    }
    
    if (requestSuccess) {
        requestModel.responseObject = responseObject;
        [self requestDidSuccessWithRequestModel:requestModel];
    } else {
        [self requestDidFailedWithRequestModel:requestModel error:requestError];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleRequestFinished:requestModel];
    });
}

- (void)requestDidSuccessWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    if (requestModel.cacheDuration > 0) {
        requestModel.responseData = [NSJSONSerialization dataWithJSONObject:requestModel.responseObject options:NSJSONWritingPrettyPrinted error:nil];
        if (requestModel.responseData) {
            [_cacheManager writeCacheWithRequestModel:requestModel asynchrously:true];
        } else {
            NSLog(@"写入缓存失败,数据转换失败");
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_isDebugMode) {
            NSLog(@"请求成功,请求url:%@,请求响应:%@",requestModel.requestUrl, requestModel.responseObject);
        }
        
        if (requestModel.successBlock) {
            requestModel.successBlock(requestModel.responseObject);
        }
    });
}

- (void)requestDidFailedWithRequestModel:(MTTNetworkRequestModel *)requestModel error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_isDebugMode) {
            NSLog(@"请求失败 请求model:%@ error:%@ 错误码:%ld",requestModel, error, error.code);
        }
        if (requestModel.failureBlock) {
            requestModel.failureBlock(requestModel.task, error, error.code);
        }
    });
}

- (void)handleRequestFinished:(MTTNetworkRequestModel *)requestModel {
    [requestModel clearAllBlocks];
    [[MTTNetworkRequestPool sharedPool] removeRequestModel:requestModel];
}

@end
