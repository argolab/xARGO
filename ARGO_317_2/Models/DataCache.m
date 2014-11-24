//
//  DataCache.m
//  xARGO
//
//  Created by 490021684@qq.com on 14-4-23.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

static DataCache * instance = nil;
+(DataCache *) Instance
{
    @synchronized(self)
    {
        if(nil == instance)
        {
            [self new];
        }
    }
    return instance;
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}


//缓存boardsAll data:
-(void)saveBoardsAllDataCache:(NSArray *)data
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings removeObjectForKey:@"allBoardsDataCache"];
    [settings setObject:data forKey:@"allBoardsDataCache"];
    [settings synchronize];
}

-(NSArray *)getBoardsAllDataCache
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    return [settings objectForKey:@"allBoardsDataCache"];
}




@end
