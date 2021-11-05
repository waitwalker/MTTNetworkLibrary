//
//  MTTNetworkUtils.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 缓存路径名称
extern NSString * _Nonnull const kNetworkCacheBaseFolderName;

/// 缓存文件前缀
extern NSString * _Nonnull const kNetworkCacheFileSuffix;

/// 缓存信息文件前缀
extern NSString * _Nonnull const kNetworkCacheInfoFileSuffix;

/// 下载文件断点续传信息文件前缀
extern NSString * _Nonnull const kNetworkDownloadResumeDataInfoFileSuffix;

@interface MTTNetworkUtils : NSObject


/// 获取app 版本
+ (NSString * _Nonnull)appVersion;


/// 根据给定的字符串生产md5
/// @param string 给定的string
+ (NSString * _Nonnull)generateMD5StringFromString:(NSString * _Nonnull)string;


/// 生成请求全路径
/// @param baseURL base url
/// @param requestURL 请求的url,一般是接口api
+ (NSString * _Nonnull)generateFullURLWithBaseURL:(NSString * _Nonnull)baseURL andRequestURL:(NSString * _Nonnull)requestURL;


/// 生成请求id
/// @param baseURL base url
/// @param requestURL 请求url, 一般是接口api
+ (NSString * _Nonnull)generateRequestIdentifierWithBaseURL:(NSString *_Nullable)baseURL
                                                 requestURL:(NSString * _Nullable)requestURL;

/// 生成请求id
/// @param baseURL base url
/// @param requestURL 请求url
/// @param method 请求方法
+ (NSString * _Nonnull)generateRequestIdentifierWithBaseURL:(NSString *_Nullable)baseURL
                                                 requestURL:(NSString * _Nullable)requestURL
                                                     method:(NSString * _Nullable)method;


/// 生成请求id
/// @param baseURL base url
/// @param requestURL 请求url
/// @param method 请求方法
/// @param parameters 请求参数
+ (NSString * _Nonnull)generateRequestIdentifierWithBaseURL:(NSString *_Nullable)baseURL
                                                 requestURL:(NSString * _Nullable)requestURL
                                                     method:(NSString * _Nullable)method
                                                 parameters:(id  _Nullable)parameters;


/// 下载任务生成请求id
/// @param baseURL base url
/// @param requestURL 请求url
+ (NSString * _Nonnull)generateDownloadRequestIdentiferWithBaseURL:(NSString *_Nullable)baseURL requestURL:(NSString *_Nonnull)requestURL;



/// 根据文件夹名称生成base路径
/// @param folderName 文件夹名称
+ (NSString * _Nonnull)createBasePathWithFolderName:(NSString * _Nonnull)folderName;



/// 创建缓存base 路径
+ (NSString * _Nonnull)createCacheBasePath;


/// 根据请求id获取缓存文件路径
/// @param requestIdentifer 请求id
+ (NSString * _Nonnull)cacheDataFilePathWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer;


/// 根据请求id获取缓存文件信息文件路径
/// @param requestIdentifer 请求id
+ (NSString * _Nonnull)cacheDataInfoFilePathWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer;


/// 获取下载文件缓存路径
/// @param requestIdentifer 请求id
/// @param downloadFileName 下载文件名称
+ (NSString * _Nonnull)resumeDataFilePathWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer downloadFileName:(NSString * _Nonnull)downloadFileName;


/// 获取下载缓存文件信息文件路径
/// @param requestIdentifer 请求id
+ (NSString * _Nonnull)resumeDataInfoFilePathWithRequestIdentifer:(NSString * _Nonnull)requestIdentifer;


/// 给定的data是否可用
/// @param data data
+ (BOOL)availableOfData:(NSData * _Nonnull)data;


/// 根据data获取图片类型
/// @param imageData 图片数据
+ (NSString * _Nullable)imageFileTypeForImageData:(NSData * _Nonnull)imageData;

@end

NS_ASSUME_NONNULL_END
