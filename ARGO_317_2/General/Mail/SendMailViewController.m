//
//  SendMailViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "SendMailViewController.h"

@interface SendMailViewController ()

@end

@implementation SendMailViewController
@synthesize mailTitleStr,contentStr,receiverStr;

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
    loadingHud.labelText=@"发送中..";
    
    //初始化completedHud
    completedHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:completedHud];
    completedHud.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    completedHud.mode=MBProgressHUDModeCustomView;
    completedHud.delegate=self;
    completedHud.labelText=@"发送成功！";
    
    //定义contentTextView边框
    self.contentTextView.layer.borderColor=[UIColor blackColor].CGColor;
    self.contentTextView.layer.borderWidth =1.0;
    
    //定义loginAlert边框
    self.loginAlert.layer.borderColor=[UIColor blackColor].CGColor;
    self.loginAlert.layer.borderWidth=1.0;
    
    //添加观察者,以便接收从loginView中过来的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInfoView) name:@"ReloadSendMailView" object:nil];
    //加载infoView：
    [self loadInfoView];
    
    //传过来的参数赋值给textField和textView
    self.receiverTextField.text=receiverStr;
    self.mailTitleTextField.text=mailTitleStr;
    self.contentTextView.text=contentStr;
    
}

-(void)loadInfoView
{
    if ([Config Instance].isLogin==NO) {
        [self.contentTextView setHidden:YES];
        [self.loginAlert setHidden:NO];
        [self.loginBtn setHidden:NO];
    }else if ([Config Instance].isLogin==YES){
        [self.contentTextView setHidden:NO];
        [self.loginAlert setHidden:YES];
        [self.loginBtn setHidden:YES];
    }
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

- (void)exit {
    //关闭发信页面
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)click_sendBtn:(id)sender
{
    if ([Config Instance].isLogin==NO) {
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"未登录" message:@"登录后才能发信" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }else if ([Config Instance].isLogin==YES){
        
        //判断收信人和信件标题是否为空
        if (self.receiverTextField.text.length==0||self.mailTitleTextField.text.length==0) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"信件接收人和信件标题不能为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            [loadingHud show:YES];
            NSString *receiver=self.receiverTextField.text;
            NSString *mailtitle=self.mailTitleTextField.text;
            NSString *content=self.contentTextView.text;
            
            NSDictionary *param=@{@"title": mailtitle,@"content":content,@"receiver":receiver};
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/mail/send";
            
            [[AFHTTPRequestOperationManager manager]POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *requestTmp = [NSString stringWithString:operation.responseString];
                
                NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                //系统自带JSON解析：
                NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                //NSLog(@"login_resultDict------------------>%@",resultDict);
                int success=[[resultDict objectForKey:@"success"]intValue];
                if (success==1) {
                    
                    //马上隐藏loadingHud:
                    [loadingHud hide:YES afterDelay:0];
                    //提示登录成功:
                    [completedHud show:YES];
                    //停留1秒后消失
                    [completedHud hide:YES afterDelay:1.0];
                    
                    //关闭发信页面
                    [self performSelector:@selector(exit) withObject:nil afterDelay:1.0];
                    
                }else{
                    
                    [loadingHud hide:YES];
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"发信失败啦" message:@"可重新登录后试试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    [alertView show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [loadingHud hide:YES];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"发表失败啦" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];
                
            }];
            
        }
        
        
    }
    

}

- (IBAction)click_cancelBtn:(id)sender
{
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
    
}


//输入之后,点击屏幕其他地方键盘消失
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.receiverTextField isFirstResponder] && [touch view] !=self.receiverTextField)
    {
        [self.receiverTextField resignFirstResponder];
    }
    if ([self.mailTitleTextField isFirstResponder] && [touch view] !=self.mailTitleTextField) {
        [self.mailTitleTextField resignFirstResponder];
    }
    if ([self.contentTextView isFirstResponder] && [touch view] !=self.contentTextView) {
        [self.contentTextView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}





@end
