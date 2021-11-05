//
//  MTTNetworkBaseEngine.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/2.
//

#import "MTTNetworkBaseEngine.h"

@implementation MTTNetworkBaseEngine

- (void)addCustomHeaders {}

- (id)addDefaultParameterWithCustomParameters:(id)parameters {
    return nil;
}

- (void)requestDidSuccessWithRequestModel:(MTTNetworkRequestModel *)requestModel {}

- (void)requestDidFailedWithRequestModel:(MTTNetworkRequestModel *)requestModel error:(NSError *)error {}


@end
