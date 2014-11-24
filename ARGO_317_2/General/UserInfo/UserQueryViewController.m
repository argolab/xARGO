//
//  UserQueryViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-19.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "UserQueryViewController.h"
#import "SendMailViewController.h"

@interface UserQueryViewController ()

@end

@implementation UserQueryViewController
@synthesize userid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化loadingHud:
    loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loadingHud];
    loadingHud.delegate=self;
    loadingHud.labelText=@"数据加载中..";

    //从服务器加载数据：
    [self fetchUserInfoFromeServerWith:userid];
    
}

-(void)fetchUserInfoFromeServerWith:(NSString *)useridStr
{
    [loadingHud show:YES];
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/user/query";
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"userid":useridStr}];
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        //NSLog(@"success------------------------>%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"userInfo_resultDict------------------>%@",resultDict);
        
        NSDictionary *userInfoData=[resultDict objectForKey:@"data"];
        
        
        self.userInfoTextField.text=[NSString stringWithFormat:@"%@（%@）共上站%@次，发表过%@篇文章。\n生命力值为%@，是否male：%@(空为否，1为是），星座为%@，信箱：%@\n签名档：%@",[userInfoData objectForKey:@"userid"],[userInfoData objectForKey:@"username"],[userInfoData objectForKey:@"numlogins"],[userInfoData objectForKey:@"numposts"],[userInfoData objectForKey:@"life_value"],[userInfoData objectForKey:@"male"],[userInfoData objectForKey:@"constellation"],[userInfoData objectForKey:@"has_mail"],[userInfoData objectForKey:@"signature"]];
        
        [loadingHud hide:YES];
        
        //释放掉用过的变量
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        userInfoData=nil;
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        [loadingHud hide:YES];
        
        //NSLog(@"Failure: %@", operation.error);
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSendMailFromUserInfoView"]) {
        
        SendMailViewController *sendMailViewController=segue.destinationViewController;
        
        sendMailViewController.receiverStr=self.userid;
        
        sendMailViewController=nil;
        
    }
}

@end
