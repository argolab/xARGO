//
//  CheckNetwork.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-22.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"

@implementation CheckNetwork

+(BOOL)isExistenceNetwork
{
    /*
    BOOL isExistenceNetwork;
    Reachability *reach=[Reachability reachabilityWithHostName:@"http://argo.sysu.edn.cn"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=NO;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=YES;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=YES;
            break;
    }
    return isExistenceNetwork;
     */
    return YES;
}

@end
