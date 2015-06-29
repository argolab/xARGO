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

// List of topics by boardname.
NSString * const ARGO_TOPIC_LIST_BY_BOARD_URL   = @"http://argo.sysu.edu.cn/ajax/post/list";

// Delete specific post.
NSString * const ARGO_POST_DELETE_URL           = @"http://argo.sysu.edu.cn/ajax/post/del";

// Check if there is new mail/alert.
NSString * const ARGO_MAIL_CHECK_URL            = @"http://argo.sysu.edu.cn/ajax/mail/check";

NSString * const MSG_NETWORK_FAILURE            = @"MSG_NETWORK_FAILURE";
NSString * const MSG_BUSINESS_FAILURE           = @"MSG_BUSINESS_FAILURE";

DataManager *manager;

+ (instancetype)manager {
    if(manager == nil){
        manager = [self alloc];
        manager.postCache = [[NSCache alloc] init];
        manager.postCache.countLimit = 5000;
    }
    return manager;
}

#pragma mark -
// Should only be used internally
- (void)getData:(NSString*) url
              withParam:(NSDictionary*) param
           withCacheKey:(NSString*) cacheKey
          withContainer:(id)container
                success:(void (^)(NSDictionary *resultDict))success
                failure:(void (^)(NSString *data, NSError *error))failure; {
    NSDictionary *resultInCache = [container objectForKey:cacheKey];
    if (resultInCache) {
        // NSLog(@"Cache hit!");
        success(resultInCache);
        return;
    }
    
    [[AFHTTPRequestOperationManager manager] GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [container setObject:responseObject forKey:cacheKey];
        NSError* error = [self isSuccessfulJsonResponse:responseObject];
        if (!error) {
            success(responseObject);
        } else {
            NSError* error = [NSError errorWithDomain:@"" code:123 userInfo:responseObject];
            failure(NSLocalizedString(MSG_BUSINESS_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
        }
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
        NSError* error = [self isSuccessfulJsonResponse:responseObject];
        if (!error) {
            success(responseObject);
        } else {
            failure(NSLocalizedString(MSG_BUSINESS_FAILURE, @""), error);
        }
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(NSLocalizedString(MSG_NETWORK_FAILURE, MSG_NETWORK_FAILURE_KEY),error);
    }];
}

-(NSError*) isSuccessfulJsonResponse: (id) responseObject {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* jsonDict = (NSDictionary*) responseObject;
        if ([[jsonDict objectForKey:@"success"] isEqual:@"1"] ||
            [[jsonDict objectForKey:@"success"] isEqual:@(1)] ||
            [jsonDict objectForKey:@"data"] ){
            return nil;
        }
        return [NSError errorWithDomain:@"" code:[[jsonDict objectForKey:@"code"] integerValue] userInfo:responseObject];
    }
    // Should not happen.
    return [NSError errorWithDomain:@"" code:404 userInfo:responseObject];
}

- (void)getAllSections:(void (^)(NSDictionary *resultDict)) success
               failure:(void (^)(NSString *data, NSError *error)) failure; {
    NSString *cacheKey = @"allSection";
    [self getData:ARGO_SECTIONS_URL withParam:nil withCacheKey:cacheKey withContainer:[NSUserDefaults standardUserDefaults]success:success failure:failure];
}

- (void)getBoardsBySection:(NSString *) secCode
                   success:(void (^)(NSDictionary *resultDict))success
                   failure:(void (^)(NSString *data, NSError *error))failure; {
    NSString *cacheKey=[@"section" stringByAppendingString:secCode];
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"sec_code":secCode}];
    [self getData:ARGO_BOARDS_GET_BY_SECTION_URL withParam:param withCacheKey:cacheKey withContainer:[NSUserDefaults standardUserDefaults] success:success failure:failure];
}

- (void)getPostByBoard:(NSString *) boardName
               andFile:(NSString *) fileName
           forceReload:(BOOL) isForceReload
               success:(void (^)(NSDictionary *resultDict))success
               failure:(void (^)(NSString *data, NSError *error))failure; {
    NSString *cacheKey=[boardName stringByAppendingString:fileName];
    if (isForceReload) {
        [self removeCacheByKey:cacheKey];
    }
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [self getData:ARGO_POST_GET_URL withParam:param withCacheKey:cacheKey withContainer:self.postCache success:success failure:failure];
}

- (void) getBoardByBoardName:(NSString *) boardName
                   success:(void (^)(NSDictionary *resultDict))success
                   failure:(void (^)(NSString *data, NSError *error))failure {
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName}];
    [self getData:ARGO_BOARD_GET_URL withParam:param success:success failure:failure];
}

- (void) getTopicByBoardName:(NSString *) boardName
                 andStartNum:(NSInteger) startNum
                     success:(void (^)(NSDictionary *resultDict))success
                     failure:(void (^)(NSString *data, NSError *error))failure {
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName, @"type":@"topic",@"start":[NSNumber numberWithInteger:startNum]}];
    [self getData:ARGO_TOPIC_LIST_BY_BOARD_URL withParam:param success:success failure:failure];
}

- (void) getPostsPerTopicByBoardName:(NSString *) boardName
                    andFile:(NSString *) fileName
                    success:(void (^)(NSDictionary *resultDict))success
                    failure:(void (^)(NSString *data, NSError *error))failure; {
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"filename":fileName}];
    [self getData:ARGO_POSTS_PER_TOPIC_URL withParam:param success:success failure:failure];
}

- (void) deletePostByBoard:(NSString *) boardName
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

- (void) checkMail:(void (^)(NSDictionary *resultDict))success
           failure:(void (^)(NSString *data, NSError *error))failure {
    NSDictionary *param=[[NSDictionary alloc]init];
    [self getData:ARGO_MAIL_CHECK_URL withParam:param success:success failure:failure];
}


- (int)getHighWaterMark:(NSString *) boardName andFile: (NSString *) fileName {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[boardName stringByAppendingString:fileName]] intValue];
}

- (void)setHighWaterMark:(NSString *) boardName andFile: (NSString *) fileName mark:(int) highWaterMark {
    if (highWaterMark > [self getHighWaterMark:boardName andFile:fileName]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(highWaterMark) forKey:[boardName stringByAppendingString:fileName]];
    }
}

- (void) removeCacheByKey:(NSString*) cacheKey {
    [self.postCache removeObjectForKey:cacheKey];
    return;
}
@end
