//
//  DataManager.h
//  xARGO
//
//  Created by exiaomo on 29/11/14.
//  Copyright (c) 2014 490021684@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSCache *postCache;

+ (DataManager *) manager;

- (void)getAllSections:(void (^)(NSDictionary *resultDict)) success
               failure:(void (^)(NSString *data, NSError *error)) failure;

- (void)getBoardsBySection:(NSString *)secCode
               success:(void (^)(NSDictionary *data))success
               failure:(void (^)(NSString *data, NSError *error))failure;

- (void)getPostByBoard:(NSString *)boardName andFile:(NSString *)fileName forceReload:(BOOL) isForceReload
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSString *data, NSError *error))failure;

- (void)getPostsPerTopicByBoardName:(NSString *) boardName andFile: (NSString *) fileName
                    success:(void (^)(NSDictionary *resultDict))success
                    failure:(void (^)(NSString *data, NSError *error))failure;

- (void)deletePostByBoard:(NSString *) boardName andFile: (NSString *) fileName
                  success:(void (^)(NSDictionary *resultDict))success
                  failure:(void (^)(NSString *data, NSError *error))failure;

- (void)getBoardByBoardName:(NSString *) boardname
                  success:(void (^)(NSDictionary *resultDict))success
                  failure:(void (^)(NSString *data, NSError *error))failure;

- (void) getTopicByBoardName:(NSString *) boardName
                 andStartNum:(NSInteger) startNum
                     success:(void (^)(NSDictionary *resultDict))success
                     failure:(void (^)(NSString *data, NSError *error))failure;

- (void) checkMail:(void (^)(NSDictionary *resultDict))success
           failure:(void (^)(NSString *data, NSError *error))failure;

- (int)getHighWaterMark:(NSString *) boardName andFile: (NSString *) fileName;
- (void)setHighWaterMark:(NSString *) boardName andFile: (NSString *) fileName mark:(int) highWaterMark;

@end
