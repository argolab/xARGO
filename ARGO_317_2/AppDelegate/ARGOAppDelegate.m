//
//  ARGOAppDelegate.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "ARGOAppDelegate.h"
#import "../Models/Config.h"


//Reachibility.h

@implementation ARGOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //自动登录
    if ([[Config Instance]getUserName]&&[[Config Instance]getPwd]) {
        [self loginWithUserid:[[Config Instance]getUserName] passwd:[[Config Instance]getPwd]];
    }
    
    return YES;
}


- (void)loginWithUserid:(NSString *)name passwd:(NSString *)pwd
{

    NSDictionary *param=@{@"userid":name,@"passwd":pwd};
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/login";
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    [manager POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"sucess--------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"login_resultDict------------------>%@",resultDict);
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            //将登录状态存入cookie
            [Config Instance].isLogin=YES;
            [[Config Instance]saveCookie:[Config Instance].isLogin];
            
        }
    } failure:nil];

}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [Config Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    if ([Config Instance].isNetworkRunning == NO) {
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络未连接" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
		[myalert show];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
