//
//  MTTNetworkUtils.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/28.
//

#import "MTTNetworkUtils.h"
#import <CommonCrypto/CommonDigest.h>

#define CC_MD5_DIGEST_LENGTH 16 /// md5摘要长度 默认16字节
#define CC_MD5_BLOCK_BYTES 64
#define CC_MD5_BLOCK_LONG (CC_MD5_BLOCK_BYTES / sizeof(CC_LONG))

/// 缓存路径名称
NSString * const kNetworkCacheBaseFolderName = @"MTTNetworkCache";

/// 缓存文件前缀
NSString * const kNetworkCacheFileSuffix = @"cacheData";

/// 缓存信息文件前缀
NSString * const kNetworkCacheInfoFileSuffix = @"cacheInfo";

/// 下载文件断点续传信息文件前缀
NSString * const kNetworkDownloadResumeDataInfoFileSuffix = @"resumeInfo";

@implementation MTTNetworkUtils

+ (NSString *)appVersion {
    return [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)generateMD5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && string.length > 0);
    const char *value = string.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc]initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

+ (NSString *)generateFullURLWithBaseURL:(NSString *)baseURL andRequestURL:(NSString *)requestURL {
    NSURL *rURL = [NSURL URLWithString:requestURL];
    if (rURL && rURL.host && rURL.scheme) {
        return requestURL;
    }
    
    NSURL *url = [NSURL URLWithString:baseURL];
    if (baseURL.length > 0 && ![baseURL hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    return [NSURL URLWithString:requestURL relativeToURL:url].absoluteString;
}

+ (NSString *)generateRequestIdentifierWithBaseURL:(NSString *)baseURL requestURL:(NSString *)requestURL method:(NSString *)method {
    NSString *urlMd5 = nil;
    NSString *methodMd5 = nil;
    NSString *identifer = nil;
    
    NSString *hostMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Host:%@",baseURL]];
    if (requestURL.length == 0 && method.length == 0) {
        identifer = [NSString stringWithFormat:@"%@",hostMd5];
    } else if (requestURL.length > 0 && method.length == 0) {
        urlMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Url:%@", requestURL]];
        identifer = [NSString stringWithFormat:@"%@_%@",hostMd5,urlMd5];
    } else if (requestURL.length > 0 && method.length > 0) {
        urlMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Url:%@",requestURL]];
        methodMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Method:%@",method]];
        identifer = [NSString stringWithFormat:@"%@_%@_%@",hostMd5, urlMd5, methodMd5];
    }
    return identifer;
}

+ (NSString *)generateRequestIdentifierWithBaseURL:(NSString *)baseURL
                                        requestURL:(NSString *)requestURL
                                            method:(NSString *)method
                                        parameters:(id)parameters {
    NSString *hostMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Host:%@",baseURL]];
    NSString *urlMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Url:%@",requestURL]];
    NSString *methodMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Method:%@",method]];
    NSString *parameterStr = @"";
    NSString *parameterMd5 = @"";
    if (parameters) {
        parameterStr = [self pConvertJSONStringWithObject:parameters];
        parameterMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Parameters:%@",parameterStr]];
    }
    NSString *identifer = [NSString stringWithFormat:@"%@_%@_%@_%@",hostMd5,urlMd5,methodMd5,parameterMd5];
    return identifer;
}

+ (NSString *)generateRequestIdentifierWithBaseURL:(NSString *)baseURL requestURL:(NSString *)requestURL {
    NSString *hostMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Host:%@",baseURL]];
    NSString *urlMd5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Url:%@",requestURL]];
    NSString *identifer = [NSString stringWithFormat:@"%@_%@", hostMd5, urlMd5];
    return identifer;
}

+ (NSString *)generateDownloadRequestIdentiferWithBaseURL:(NSString *)baseURL requestURL:(NSString *)requestURL {
    NSString *hostMD5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Host:%@",baseURL]];
    NSString *urlMD5 = [self generateMD5StringFromString:[NSString stringWithFormat:@"Url:%@",requestURL]];
    NSString *requestIdentifer = [NSString stringWithFormat:@"%@_%@_",hostMD5,urlMD5];
    return requestIdentifer;
}

+ (NSString *)createBasePathWithFolderName:(NSString *)folderName {
    NSString *pathDomain = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true) objectAtIndex:0];
    NSString *path = [pathDomain stringByAppendingPathComponent:folderName];
    [self pCreateDirectoryIfNeeded:path];
    return path;
}

+ (NSString *)createCacheBasePath {
    return [self createBasePathWithFolderName:kNetworkCacheBaseFolderName];
}

+ (NSString *)cacheDataFilePathWithRequestIdentifer:(NSString *)requestIdentifer {
    if (requestIdentifer.length > 0) {
        NSString *cacheFileName = [NSString stringWithFormat:@"%@.%@",requestIdentifer, kNetworkCacheFileSuffix];
        NSString *cacheFilePath = [[self createCacheBasePath] stringByAppendingPathComponent:cacheFileName];
        return cacheFilePath;
    } else {
        return nil;
    }
}

+ (NSString *)cacheDataInfoFilePathWithRequestIdentifer:(NSString *)requestIdentifer {
    if (requestIdentifer.length > 0) {
        NSString *cacheFileName = [NSString stringWithFormat:@"%@.%@",requestIdentifer, kNetworkCacheInfoFileSuffix];
        NSString *cacheFilePath = [[self createCacheBasePath] stringByAppendingPathComponent:cacheFileName];
        return cacheFilePath;
    } else {
        return nil;
    }
}

+ (NSString *)resumeDataInfoFilePathWithRequestIdentifer:(NSString *)requestIdentifer {
    NSString *dataFileName = [NSString stringWithFormat:@"%@.%@", requestIdentifer, kNetworkDownloadResumeDataInfoFileSuffix];
    NSString *resumeDataInfoFilePath = [[self createCacheBasePath] stringByAppendingPathComponent:dataFileName];
    return resumeDataInfoFilePath;
}

+ (NSString *)resumeDataFilePathWithRequestIdentifer:(NSString *)requestIdentifer downloadFileName:(NSString *)downloadFileName {
    NSString *dataFileName = [NSString stringWithFormat:@"%@.%@", requestIdentifer, downloadFileName];
    NSString *resumeDataFilePath = [[self createCacheBasePath] stringByAppendingPathComponent:dataFileName];
    return resumeDataFilePath;
}

+ (NSString *)pConvertJSONStringWithObject:(id)parameter {
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (BOOL)availableOfData:(NSData *)data {
    if (!data || data.length == 0) return false;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) {
        return false;
    }
    return true;
}

+ (NSString *)imageFileTypeForImageData:(NSData *)imageData {
    /// 图片数据的第一个字节是固定的,一种类型的图片第一个字节就是它的标识
    uint8_t c;
    [imageData getBytes:&c length:1];
    switch (c) {
        case 0xff:
            return @"jpeg";
            break;
        case 0x89:
            return @"png";
            break;
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4d:
            return @"tiff";
            break;
        case 0x52:
            if (imageData.length < 12) {
                return nil;
            }
            NSString *imageString = [[NSString alloc]initWithData:[imageData subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([imageString hasPrefix:@"RIFF"] || [imageString hasSuffix:@"WEBP"]) {
                return @"web";
            }
            return nil;
            break;
    }
    return nil;
}

+ (void)pCreateDirectoryIfNeeded:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self pCreateBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self pCreateBaseDirectoryAtPath:path];
        }
    }
}

+ (void)pCreateBaseDirectoryAtPath:(NSString *)path {
    [[NSFileManager defaultManager]createDirectoryAtPath:path
                             withIntermediateDirectories:true
                                              attributes:nil
                                                   error:nil];
}

@end
