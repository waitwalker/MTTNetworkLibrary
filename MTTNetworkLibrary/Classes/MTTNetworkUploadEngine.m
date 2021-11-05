//
//  MTTNetworkUploadEngine.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/4.
//

#import "MTTNetworkUploadEngine.h"
#import "MTTNetworkRequestPool.h"
#import "MTTNetworkConfig.h"
#import "MTTNetworkUtils.h"
#import "MTTNetworkProtocol.h"

@interface MTTNetworkUploadEngine ()<MTTNetworkProtocol>

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation MTTNetworkUploadEngine {
    BOOL _isDebugMode;
}

- (instancetype)init {
    if (self = [super init]) {
        _isDebugMode = [MTTNetworkConfig sharedConfig].debugMode;
        _sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.allowsCellularAccess = true;
        _sessionManager.requestSerializer.timeoutInterval = [MTTNetworkConfig sharedConfig].timeoutSeconds;
        
        _sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        [_sessionManager.securityPolicy setAllowInvalidCertificates:true];
        _sessionManager.securityPolicy.validatesDomainName = false;
        
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [[NSSet alloc]initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain", nil];
        
        _sessionManager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

- (void)fetchUploadImageRequest:(NSString *)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id)parameters
                         images:(NSArray<UIImage *> *)images
                  compressRatio:(float)compressRation
                           name:(NSString *)name
                       mimeType:(NSString *)mimeType
                       progress:(MTTUploadProgressBlock)uploadProgressBlock
                        success:(MTTUploadSuccessBlock)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock)uploadFailureBlock {
    if (images.count == 0) {
        NSLog(@"上传图片失败,图片列表为空");
        return;
    }
    
    NSString *methodStr = @"POST";
    NSString *fullURLStr;
    NSString *requestIdentifer;
    if (ignoreBaseURL) {
        fullURLStr = url;
        requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:nil requestURL:url method:methodStr parameters:parameters];
    } else {
        fullURLStr = [[MTTNetworkConfig sharedConfig].baseUrl stringByAppendingPathComponent:url];
        requestIdentifer = [MTTNetworkUtils generateRequestIdentifierWithBaseURL:[MTTNetworkConfig sharedConfig].baseUrl requestURL:url method:methodStr parameters:parameters];
    }
    
    [self addCustomHeaders];
    
    NSDictionary *fullParameters = [self addDefaultParameterWithCustomParameters:parameters];
    MTTNetworkRequestModel *requestModel = [[MTTNetworkRequestModel alloc]init];
    requestModel.requestUrl = fullURLStr;
    requestModel.uploadUrl = url;
    requestModel.method = methodStr;
    requestModel.parameters = fullParameters;
    requestModel.uploadImages = images;
    requestModel.imageCompressRatio = compressRation;
    requestModel.imageIdentier = name;
    requestModel.mimeType = mimeType;
    requestModel.requestIdentifer = requestIdentifer;
    requestModel.uploadSuccessBlock = uploadSuccessBlock;
    requestModel.uploadFailureBlock = uploadFailureBlock;
    requestModel.uploadProgressBlock = uploadProgressBlock;
    [self pUploadImagesRequestWithRequestModel:requestModel];
}

- (void)addCustomHeaders {
    NSDictionary *customHeaders = [MTTNetworkConfig sharedConfig].customHeaders;
    if (customHeaders.allKeys.count > 0) {
        [customHeaders enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
            if (_isDebugMode) {
                NSLog(@"添加请求头成功");
            }
        }];
    }
}

- (id)addDefaultParameterWithCustomParameters:(id)parameters {
    id parameterSpliced;
    if (parameters && [parameters isKindOfClass:[NSDictionary class]]) {
        if ([MTTNetworkConfig sharedConfig].defaultParameters.allKeys.count > 0) {
            NSMutableDictionary *defaultParamtersM = [[MTTNetworkConfig sharedConfig].defaultParameters mutableCopy];
            [defaultParamtersM addEntriesFromDictionary:parameters];
            parameterSpliced = [defaultParamtersM copy];
        } else {
            parameterSpliced = parameters;
        }
    } else {
        parameterSpliced = [MTTNetworkConfig sharedConfig].defaultParameters;
    }
    return parameterSpliced;
}

- (void)pUploadImagesRequestWithRequestModel:(MTTNetworkRequestModel *)requestModel {
    if (_isDebugMode) {
        NSLog(@"开始上传");
    }
    
    __weak __typeof(self) weakSelf = self;
    NSURLSessionTask *uploadTask = [_sessionManager POST:requestModel.requestUrl parameters:requestModel.parameters headers:[MTTNetworkConfig sharedConfig].customHeaders constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [requestModel.uploadImages enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            float ratio = requestModel.imageCompressRatio;
            if (ratio > 1 || ratio < 0) {
                ratio = 1;
            }
            
            NSData *imageData;
            NSString *imageType;
            if ([requestModel.mimeType isEqualToString:@"png"] || [requestModel.mimeType isEqualToString:@"PNG"]) {
                imageData = UIImagePNGRepresentation(image);
                imageType = @"png";
            } else if ([requestModel.mimeType isEqualToString:@"jpg"] || [requestModel.mimeType isEqualToString:@"JPG"]) {
                imageData = UIImageJPEGRepresentation(image, ratio);
                imageType = @"jpg";
            } else if ([requestModel.mimeType isEqualToString:@"jpeg"] || [requestModel.mimeType isEqualToString:@"JPEG"]) {
                imageData = UIImageJPEGRepresentation(image, ratio);
                imageType = @"jpeg";
            } else {
                imageData = UIImageJPEGRepresentation(image, ratio);
                imageType = @"jpg";
            }
            
            long index = idx;
            NSTimeInterval interval = [[NSDate date]timeIntervalSince1970];
            long long totalMilliseconds = interval * 1000;
            NSString *fileName = [NSString stringWithFormat:@"%lld.%@",totalMilliseconds, imageType];
            NSString *identifer = [NSString stringWithFormat:@"%@%ld",requestModel.imageIdentier,index];
            [formData appendPartWithFileData:imageData name:identifer fileName:fileName mimeType:[NSString stringWithFormat:@"image/%@", imageType]];
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (self->_isDebugMode) {
            NSLog(@"图片上传进度:%@",uploadProgress);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (requestModel.uploadProgressBlock) {
                    requestModel.uploadProgressBlock(uploadProgress);
                }
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (self->_isDebugMode) {
            NSLog(@"图片上传成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (requestModel.uploadSuccessBlock) {
                    requestModel.uploadSuccessBlock(responseObject);
                }
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self->_isDebugMode) {
            NSLog(@"图片上传失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (requestModel.uploadFailureBlock) {
                    requestModel.uploadFailureBlock(task, error, error.code, requestModel.uploadImages);
                }
                [weakSelf handleRequestFinished:requestModel];
            });
        }
    }];
    requestModel.task = uploadTask;
    [[MTTNetworkRequestPool sharedPool]addRequestModel:requestModel];
}

- (void)handleRequestFinished:(MTTNetworkRequestModel *)requestModel {
    [requestModel clearAllBlocks];
    [[MTTNetworkRequestPool sharedPool] removeRequestModel:requestModel];
}

@end
