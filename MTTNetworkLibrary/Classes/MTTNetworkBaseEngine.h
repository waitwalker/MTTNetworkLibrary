//
//  MTTNetworkBaseEngine.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/2.
//

#import <Foundation/Foundation.h>
#import "MTTNetworkRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTTNetworkBaseEngine : NSObject


/// 添加请求头
- (void)addCustomHeaders;


/// 添加默认请求参数
/// @param parameters 请求参数
- (id)addDefaultParameterWithCustomParameters:(id)parameters;


/// 请求成功
/// @param requestModel 请求model
- (void)requestDidSuccessWithRequestModel:(MTTNetworkRequestModel *)requestModel;


/// 请求失败
/// @param requestModel 请求model
- (void)requestDidFailedWithRequestModel:(MTTNetworkRequestModel *)requestModel error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
