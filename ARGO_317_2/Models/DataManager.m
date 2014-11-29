//
//  DataManager.m
//  xARGO
//
//  Created by exiaomo on 29/11/14.
//  Copyright (c) 2014 490021684@qq.com. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

NSString * const ARGO_BASE_URL = @"http://argo.sysu.edu.cn/ajax/";
NSString * const POST_GET_URL  = @"http://argo.sysu.edu.cn/ajax/post/get";

DataManager* manager;

+ (instancetype)manager {
    if(manager == nil){
        manager = [self alloc];
        manager.postCache = [[NSCache alloc] init];
    }
    return manager;
}

#pragma mark -

- (void)getPostByBoard:(NSString *) boardName andFile: (NSString *) fileName
                                   success:(void (^)(NSDictionary *resultDict))success
                                   failure:(void (^)(NSString *data, NSError *error))failure; {
    NSString *cacheKey=[boardName stringByAppendingString:fileName];
    NSDictionary *resultInCache = [self.postCache objectForKey:cacheKey];
    if (resultInCache != nil) {
        // NSLog(@"Cache hit!");
        success(resultInCache);
        return;
    }
     NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];

    [[AFHTTPRequestOperationManager manager] GET:POST_GET_URL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"success------------------------>%@",operation.responseObject);
        NSString *responseString = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        
        [self.postCache setObject:resultDict forKey:cacheKey];
        success(resultDict);

        responseObject=nil;
        resData=nil;
        resultDict=nil;
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(@"Failed on Network communication.",error);
    }];
}


@end
