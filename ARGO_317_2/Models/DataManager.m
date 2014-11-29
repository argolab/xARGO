//
//  DataManager.m
//  xARGO
//
//  Created by exiaomo on 29/11/14.
//  Copyright (c) 2014 490021684@qq.com. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

NSString * const ARGO_BASE_URL              = @"http://argo.sysu.edu.cn/ajax/";
NSString * const ARGO_POST_GET_URL          = @"http://argo.sysu.edu.cn/ajax/post/get";
NSString * const ARGO_POST_TOPICLIST_URL    = @"http://argo.sysu.edu.cn/ajax/post/topiclist";
NSString * const ARGO_POST_DELETE_URL       = @"http://argo.sysu.edu.cn/ajax/post/del";

NSString * const MSG_NETWORK_FAILURE        = @"MSG_NETWORK_FAILURE";

DataManager *manager;

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
    if (resultInCache) {
        // NSLog(@"Cache hit!");
        success(resultInCache);
        return;
    }

    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [[AFHTTPRequestOperationManager manager] GET:ARGO_POST_GET_URL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = responseObject;
        [self.postCache setObject:resultDict forKey:cacheKey];
        success(resultDict);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(NSLocalizedString(MSG_NETWORK_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
    }];
}

- (void)getTopicListByBoard:(NSString *) boardName andFile: (NSString *) fileName
               success:(void (^)(NSDictionary *resultDict))success
               failure:(void (^)(NSString *data, NSError *error))failure; {
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [[AFHTTPRequestOperationManager manager] GET:ARGO_POST_TOPICLIST_URL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = responseObject;
        success(resultDict);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(NSLocalizedString(MSG_NETWORK_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
    }];
}

- (void)deletePostByBoard:(NSString *) boardName andFile: (NSString *) fileName
               success:(void (^)(NSDictionary *resultDict))success
               failure:(void (^)(NSString *data, NSError *error))failure; {
    NSString *cacheKey=[boardName stringByAppendingString:fileName];
    NSDictionary *resultInCache = [self.postCache objectForKey:cacheKey];
    if (resultInCache) {
        // NSLog(@"Remove item from cache!");
        [self.postCache removeObjectForKey:cacheKey];
    }

    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [[AFHTTPRequestOperationManager manager] DELETE:ARGO_POST_DELETE_URL parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *resultDict = responseObject;
        [self.postCache setObject:resultDict forKey:cacheKey];
        success(resultDict);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(NSLocalizedString(MSG_NETWORK_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
    }];

}

@end
