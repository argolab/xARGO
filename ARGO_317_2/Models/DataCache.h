//
//  DataCache.h
//  xARGO
//
//  Created by 490021684@qq.com on 14-4-23.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCache : NSObject

+(DataCache *) Instance;
+(id)allocWithZone:(NSZone *)zone;

//缓存boardsAll data:
-(void)saveBoardsAllDataCache:(NSArray *)data;
-(NSArray *)getBoardsAllDataCache;


@end
