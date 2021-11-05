//
//  MTTNetworkProtocol.h
//  NetworkLibrary
//
//  Created by waitwalker on 2021/11/2.
//

#import <Foundation/Foundation.h>

@class MTTNetworkRequestModel;

NS_ASSUME_NONNULL_BEGIN

@protocol MTTNetworkProtocol <NSObject>

@required

- (void)handleRequestFinished:(MTTNetworkRequestModel *)requestModel;

@end

NS_ASSUME_NONNULL_END
