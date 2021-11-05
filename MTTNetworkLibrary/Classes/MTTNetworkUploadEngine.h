//
//  MTTNetworkUploadEngine.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/4.
//

#import <MTTNetworkLibrary/MTTNetworkLibrary.h>
#import "MTTNetworkBaseEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkUploadEngine : MTTNetworkBaseEngine


/// 上传请求
/// @param url 请求url
/// @param ignoreBaseURL 是否忽略base url
/// @param parameters 请求参数
/// @param images 图片列表
/// @param compressRation 压缩比例
/// @param mimeType 网络媒体类型
/// @param name 网络名称
/// @param uploadProgressBlock 上传进度回调
/// @param uploadSuccessBlock 上传成功回调
/// @param uploadFailureBlock 上传失败回调
- (void)fetchUploadImageRequest:(NSString *_Nonnull)url
                  ignoreBaseURL:(BOOL)ignoreBaseURL
                     parameters:(id _Nullable)parameters
                         images:(NSArray<UIImage *> *_Nonnull)images
                  compressRatio:(float)compressRation
                           name:(NSString *_Nonnull)name
                       mimeType:(NSString *_Nonnull)mimeType
                       progress:(MTTUploadProgressBlock _Nullable)uploadProgressBlock
                        success:(MTTUploadSuccessBlock _Nullable)uploadSuccessBlock
                        failure:(MTTUploadFailureBlock _Nullable)uploadFailureBlock;

@end

NS_ASSUME_NONNULL_END
