//
//  MTTNetworkConfig.m
//  NetworkLibrary
//
//  Created by waitwalker on 2021/10/28.
//

#import "MTTNetworkConfig.h"

@interface MTTNetworkConfig ()

@property (nonatomic, readwrite, strong) NSDictionary *customHeaders;

@end

@implementation MTTNetworkConfig

+ (instancetype)sharedConfig {
    static MTTNetworkConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MTTNetworkConfig alloc]init];
    });
    return instance;
}

- (void)addCustomHeader:(NSDictionary *)header {
    if (![header isKindOfClass:[NSDictionary class]] || header.count == 0) return;
    
    if (_customHeaders == nil) {
        _customHeaders = header;
        return;
    }
    
    NSMutableDictionary *headersM = [_customHeaders mutableCopy];
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [headersM setObject:obj forKey:key];
    }];
    _customHeaders = [headersM copy];
}

@end
