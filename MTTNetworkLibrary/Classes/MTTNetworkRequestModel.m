//
//  MTTNetworkReuestModel.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/27.
//

#import "MTTNetworkRequestModel.h"
#import "MTTNetworkUtils.h"
#import "MTTNetworkConfig.h"

@interface MTTNetworkRequestModel ()
@property (nonatomic, readwrite, copy) NSString *cacheDataFilePath;
@property (nonatomic, readwrite, copy) NSString *cacheDataInfoFilePath;
@property (nonatomic, readwrite, copy) NSString *resumeDataFilePath;
@property (nonatomic, readwrite, copy) NSString *resumeDataInfoFilePath;


@end

@implementation MTTNetworkRequestModel

- (MTTRequestType)requestType {
    if (self.downloadFilePath) {
        return MTTRequestTypeDownload;
    } else if (self.uploadUrl) {
        return MTTRequestTypeUpload;
    } else {
        return MTTRequestTypeOrdinary;
    }
}

- (NSString *)cacheDataFilePath {
    if (self.requestType == MTTRequestTypeOrdinary) {
        if (_cacheDataFilePath.length > 0) {
            return _cacheDataFilePath;
        } else {
            _cacheDataFilePath = [MTTNetworkUtils cacheDataFilePathWithRequestIdentifer:_requestIdentifer];
            return _cacheDataFilePath;
        }
    }
    return nil;
}

- (NSString *)cacheDataInfoFilePath {
    if (self.requestType == MTTRequestTypeOrdinary) {
        if (_cacheDataInfoFilePath.length > 0) {
            return _cacheDataInfoFilePath;
        } else {
            _cacheDataInfoFilePath = [MTTNetworkUtils cacheDataInfoFilePathWithRequestIdentifer:_requestIdentifer];
            return _cacheDataInfoFilePath;
        }
    }
    return nil;
}

- (NSString *)resumeDataFilePath {
    if (self.requestType == MTTRequestTypeDownload) {
        if (_resumeDataFilePath.length > 0) {
            return _resumeDataFilePath;
        } else {
            _resumeDataFilePath = [MTTNetworkUtils resumeDataFilePathWithRequestIdentifer:_requestIdentifer downloadFileName:_downloadFilePath.lastPathComponent];
            return _resumeDataFilePath;
        }
    }
    return nil;
}

- (NSString *)resumeDataInfoFilePath {
    if (self.requestType == MTTRequestTypeDownload) {
        if (_resumeDataInfoFilePath.length > 0) {
            return _resumeDataInfoFilePath;
        } else {
            _resumeDataInfoFilePath = [MTTNetworkUtils resumeDataInfoFilePathWithRequestIdentifer:_requestIdentifer];
            return _resumeDataInfoFilePath;
        }
    }
    return nil;
}

- (void)clearAllBlocks {
    _successBlock = nil;
    _failureBlock = nil;
    
    _uploadProgressBlock = nil;
    _uploadSuccessBlock = nil;
    _uploadFailureBlock = nil;
    
    _downloadFailureBlock = nil;
    _downloadSuccessBlock = nil;
    _downloadSuccessBlock = nil;
}

- (NSString *)description {
    if ([MTTNetworkConfig sharedConfig].debugMode) {
        switch (self.requestType) {
            case MTTRequestTypeOrdinary:
                return [NSString stringWithFormat:@"\n{\n   <%@: %p>\n   type:            oridnary request\n   method:          %@\n   url:             %@\n   parameters:      %@\n   loadCache:       %@\n   cacheDuration:   %@ seconds\n   requestIdentifer:%@\n   task:            %@\n}" ,NSStringFromClass([self class]),self,_method,_requestUrl,_parameters,_loadCache?@"YES":@"NO",[NSNumber numberWithInteger:_cacheDuration],_requestIdentifer,_task];
                break;
            case MTTRequestTypeUpload:
                return [NSString stringWithFormat:@"\n{\n   <%@: %p>\n   type:            upload request\n   method:          %@\n   url:             %@\n   parameters:      %@\n   images:          %@\n    requestIdentifer:%@\n   task:            %@\n}" ,NSStringFromClass([self class]),self,_method,_requestUrl,_parameters,_uploadImages,_requestIdentifer,_task];
                break;
            case MTTRequestTypeDownload:
                return [NSString stringWithFormat:@"\n{\n   <%@: %p>\n   type:            download request\n   method:          %@\n   url:             %@\n   parameters:      %@\n   target path:     %@\n    requestIdentifer:%@\n   task:            %@\n}" ,NSStringFromClass([self class]),self,_method,_requestUrl,_parameters,_downloadFilePath,_requestIdentifer,_task];
                break;
        }
    }
    return [NSString stringWithFormat:@"<%@: %@>",NSStringFromClass([self class]), self];
}

@end
