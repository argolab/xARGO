//
//  LoginViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginGuideViewController.h"


@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize username;
@synthesize password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//输入之后,点击屏幕其他地方键盘消失
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([username isFirstResponder] && [touch view] !=username)
    {
        [username resignFirstResponder];
    }
    if ([password isFirstResponder] && [touch view] !=password) {
        [password resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];

}

//username输入之后,按return键盘消失
- (IBAction)usernameReturn:(id)sender {
    
    [sender resignFirstResponder];
}

//password输入之后，按Done键登录
- (IBAction)passwordReturn:(id)sender {
    
    
    [sender resignFirstResponder];
    //[self login];
}

//将return键改为“done",设置密码输入保护
- (IBAction)passwordTyping:(id)sender {
    
    [password setReturnKeyType:UIReturnKeyDone];
}

- (IBAction)click_Login:(id)sender {
    
    
    [self login];

}

- (IBAction)click_cancel:(id)sender {
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [password setSecureTextEntry:YES];
    self.navigationItem.title=@"登录";
    //决定是否显示用户名以及密码
    NSString *name=[Config Instance].getUserName;
    NSString *pwd=[Config Instance].getPwd;
    //如果用户名和密码存在，且不为空，取出付给相应text
    if (name&&![name isEqualToString:@""]) {
        self.username.text=name;
    }
    if (pwd&& ![pwd isEqualToString:@""]) {
        self.password.text=pwd;
    }
    //初始化loadingHud
    loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loadingHud];
    loadingHud.delegate=self;
    loadingHud.labelText=@"登录中..";
    
    //初始化completedHud
    completedHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:completedHud];
    completedHud.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    completedHud.mode=MBProgressHUDModeCustomView;
    completedHud.delegate=self;
    completedHud.labelText=@"登录成功！";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exit {
    //关闭登录页面
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
}

- (void)login
{
    NSString *name=self.username.text;
    NSString *pwd=self.password.text;
    NSDictionary *param=@{@"userid":name,@"passwd":pwd};
    //NSLog(@"param--------------->%@",param);
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/login";
    
    //判断用户名和密码是否为空
    if (name.length==0||pwd.length==0) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"用户名或密码不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        
        //提示登录中
        [loadingHud show:YES];
        
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        
        //manager.requestSerializer=[AFJSONRequestSerializer serializer];//这句不要
        [manager POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"sucess--------------->%@",operation.responseObject);
            NSString *requestTmp = [NSString stringWithString:operation.responseString];
            NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
            //系统自带JSON解析：
            NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"login_resultDict------------------>%@",resultDict);
            int success=[[resultDict objectForKey:@"success"]intValue];
            if (success==1) {
                [[Config Instance]saveUserNameAndPwd:name andPwd:pwd];
                //将登录状态存入cookie
                [Config Instance].isLogin=YES;
                [[Config Instance]saveCookie:[Config Instance].isLogin];
                //刷新loginGuideView:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadLoginGuideView" object:nil];
                //刷新addPostView:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAddPostView" object:nil];
                //刷新sendMailView:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadSendMailView" object:nil];
                
                
                //马上隐藏loadingHud:
                [loadingHud hide:YES afterDelay:0];
                //提示登录成功:
                [completedHud show:YES];
                //停留1秒后消失
                [completedHud hide:YES afterDelay:1.0];
                [self performSelector:@selector(exit) withObject:nil afterDelay:1.0];


                
            }else{
                //马上隐藏loadingHud:
                [loadingHud hide:YES afterDelay:0];
                
                //弹出登录失败警告：
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"登录失败" message:@"请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //马上隐藏loadingHud:
            [loadingHud hide:YES afterDelay:0];
            
            //提示失败可能由于网络原因：
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"登录失败" message:[error localizedDescription] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }];
    }
    
    
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


@end


