//
//  DataManager.m
//  xARGO
//
//  Created by exiaomo on 29/11/14.
//  Copyright (c) 2014 490021684@qq.com. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

NSString * const ARGO_BASE_URL                  = @"http://argo.sysu.edu.cn/ajax/";

// Full list of sections
NSString * const ARGO_SECTIONS_URL              = @"http://argo.sysu.edu.cn/ajax/section/";

// List of boards that belong to one section
NSString * const ARGO_BOARDS_GET_BY_SECTION_URL = @"http://argo.sysu.edu.cn/ajax/board/getbysec";

// Meta info of a board.
NSString * const ARGO_BOARD_GET_URL             = @"http://argo.sysu.edu.cn/ajax/board/get";

// A list of Posts that belong to one topic.
NSString * const ARGO_POSTS_PER_TOPIC_URL       = @"http://argo.sysu.edu.cn/ajax/post/topiclist";

// A single Post get by boardname and filename.
NSString * const ARGO_POST_GET_URL              = @"http://argo.sysu.edu.cn/ajax/post/get";
// Delete specific post.
NSString * const ARGO_POST_DELETE_URL           = @"http://argo.sysu.edu.cn/ajax/post/del";


NSString * const MSG_NETWORK_FAILURE            = @"MSG_NETWORK_FAILURE";

DataManager *manager;

+ (instancetype)manager {
    if(manager == nil){
        manager = [self alloc];
        manager.postCache = [[NSCache alloc] init];
    }
    return manager;
}

#pragma mark -
// Should only be used internally
- (void)getData:(NSString*) url
              withParam:(NSDictionary*) param
           withCacheKey:(NSString*) cacheKey
                success:(void (^)(NSDictionary *resultDict))success
                failure:(void (^)(NSString *data, NSError *error))failure; {
    NSDictionary *resultInCache = [self.postCache objectForKey:cacheKey];
    if (resultInCache) {
        // NSLog(@"Cache hit!");
        success(resultInCache);
        return;
    }
    
    [[AFHTTPRequestOperationManager manager] GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.postCache setObject:responseObject forKey:cacheKey];
        success(responseObject);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(NSLocalizedString(MSG_NETWORK_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
    }];
}

// Should only be used internally
- (void)getData:(NSString*) url
              withParam:(NSDictionary*) param
                success:(void (^)(NSDictionary *resultDict))success
                failure:(void (^)(NSString *data, NSError *error))failure; {
    [[AFHTTPRequestOperationManager manager] GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(NSLocalizedString(MSG_NETWORK_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
    }];
}

- (void)getAllSections:(void (^)(NSDictionary *resultDict)) success
               failure:(void (^)(NSString *data, NSError *error)) failure; {
    NSString *cacheKey = @"allSection";
    [self getData:ARGO_SECTIONS_URL withParam:nil withCacheKey:cacheKey success:success failure:failure];
}

- (void)getBoardsBySection:(NSString *) secCode
                   success:(void (^)(NSDictionary *resultDict))success
                   failure:(void (^)(NSString *data, NSError *error))failure; {
    NSString *cacheKey=[@"section" stringByAppendingString:secCode];
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"sec_code":secCode}];
    [self getData:ARGO_BOARDS_GET_BY_SECTION_URL withParam:param withCacheKey:cacheKey success:success failure:failure];
}

- (void)getPostByBoard:(NSString *) boardName
               andFile:(NSString *) fileName
               success:(void (^)(NSDictionary *resultDict))success
               failure:(void (^)(NSString *data, NSError *error))failure; {
    NSString *cacheKey=[boardName stringByAppendingString:fileName];
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [self getData:ARGO_POST_GET_URL withParam:param withCacheKey:cacheKey success:success failure:failure];
}

- (void) getBoardByBoardName:(NSString *) boardName
                   success:(void (^)(NSDictionary *resultDict))success
                   failure:(void (^)(NSString *data, NSError *error))failure {
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName}];
    [self getData:ARGO_BOARD_GET_URL withParam:param success:success failure:failure];
}

- (void) getPostsPerTopicByBoardName:(NSString *) boardName
                    andFile:(NSString *) fileName
                    success:(void (^)(NSDictionary *resultDict))success
                    failure:(void (^)(NSString *data, NSError *error))failure; {
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [self getData:ARGO_POSTS_PER_TOPIC_URL withParam:param success:success failure:failure];
}

- (void)deletePostByBoard:(NSString *) boardName
                  andFile:(NSString *) fileName
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
