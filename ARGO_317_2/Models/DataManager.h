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

- (void)getPostByBoard:(NSString *)boardName andFile:(NSString *)fileName
                        success:(void (^)(NSDictionary *data))success
                        failure:(void (^)(NSString *data, NSError *error))failure;

- (void)getTopicListByBoard:(NSString *) boardName andFile: (NSString *) fileName
                    success:(void (^)(NSDictionary *resultDict))success
                    failure:(void (^)(NSString *data, NSError *error))failure;

- (void)deletePostByBoard:(NSString *) boardName andFile: (NSString *) fileName
                  success:(void (^)(NSDictionary *resultDict))success
                  failure:(void (^)(NSString *data, NSError *error))failure;

@end
