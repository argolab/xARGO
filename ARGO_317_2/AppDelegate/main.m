//
//  main.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif

#import <UIKit/UIKit.h>

#import "ARGOAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ARGOAppDelegate class]));
    }
}
