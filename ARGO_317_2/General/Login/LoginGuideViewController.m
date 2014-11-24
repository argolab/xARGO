//
//  LoginGuideViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "LoginGuideViewController.h"

@interface LoginGuideViewController ()

@end

@implementation LoginGuideViewController
@synthesize userInfoTextField,loginGuideTextField,loginBtn,logoutBtn;

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
    //初始化loadingHud
    loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loadingHud];
    loadingHud.delegate=self;
    loadingHud.labelText=@"注销中..";
    [loadingHud showWhileExecuting:@selector(click_logout:) onTarget:nil withObject:nil animated:YES];
    
    //添加观察者,以便接收从loginView中过来的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInfoView) name:@"ReloadLoginGuideView" object:nil];
    //加载数据
    [self loadInfoView];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)click_logout:(id)sender
{
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/logout";
    [[AFHTTPRequestOperationManager manager] POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //NSLog(@"logout_success-------------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"resultDict------------------>%@",resultDict);
        
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            
            //将登录状态存入cookie
            [Config Instance].isLogin=NO;
            [[Config Instance]saveCookie:[Config Instance].isLogin];
            
            /*
            //清空cookies    编辑于2014-10-07
            NSHTTPCookieStorage *myCookie=[NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *tmpArray=[NSArray arrayWithArray:[myCookie cookies]];
            for (id obj in tmpArray) {
                [myCookie deleteCookie:obj];
            }
             */
            
            
            //更新loginGuideView
            [self loadInfoView];
            
        }else{
            
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"注销没成功" message:@"请重试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            
        }
        //释放掉不用的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"注销没成功" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];

    }];
}

- (void)loadInfoView
{
    //如果已经登录了，显示用户信息和注销按钮，用户登录指引和登录按钮隐藏；如果用户没有登录，不显示用户信息和注销按钮。
    if ([Config Instance].isLogin==YES) {
        NSLog(@"[Config Instance].isLogin-------->1");
        [self loadUserInfo];
         loginGuideTextField.text=@"";
        [loginBtn setHidden:YES];
        [logoutBtn setHidden:NO];
    }else if ([Config Instance].isLogin==NO){
        NSLog(@"[Config Instance].isLogin-------->0");
        self.navigationItem.title=@"还没登录";
        userInfoTextField.text=@"";
        loginGuideTextField.text=@"点登录按钮登录";
        [loginBtn setHidden:NO];
        [logoutBtn setHidden:YES];
    }
    
    
}

- (void)loadUserInfo
{
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/user/info";
    [[AFHTTPRequestOperationManager manager] POST:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"UserInfo_success-------------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"UserInfo_resultDict------------------>%@",resultDict);
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            NSDictionary *dataDict=[resultDict objectForKey:@"data"];
            userInfoTextField.text=[NSString stringWithFormat:@"%@（%@）共上站%@次，发表过%@篇文章\n\n目前属于登录状态",[dataDict objectForKey:@"userid"],[dataDict objectForKey:@"username"],[dataDict objectForKey:@"numlogins"],[dataDict objectForKey:@"numposts"]];
            //NSLog(@"userInfoTextField.text------------------>%@",userInfoTextField.text);
            self.navigationItem.title=[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"userid"]];
        }else{
            userInfoTextField.text=@"用户信息加载失败";
        }
        
    } failure:nil];
}




@end
