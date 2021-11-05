//
//  MTTViewController.m
//  MTTNetworkLibrary
//
//  Created by waitwalker on 11/05/2021.
//  Copyright (c) 2021 waitwalker. All rights reserved.
//

#import "MTTViewController.h"

#import <MTTNetworkLibrary/MTTNetworkLibrary.h>

@interface MTTViewController ()

@end

@implementation MTTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self invocationTest];
    [self testNetwork];
}

- (void)testNetwork {
    [[MTTNetworkManager sharedManager] fetchPostRequest:@"https://school.etiantian.com/api-study-service/api/pad-licenses/tokens?license=liuzhongwei" parameters:@{} success:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSURLSessionTask *task, NSError *error, NSInteger statusCode) {
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
