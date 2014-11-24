//
//  AddPostViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-13.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "AddPostViewController.h"

@interface AddPostViewController ()

@end

@implementation AddPostViewController
@synthesize type,boardName,articleid,titleParam,content,attach,rawcontent,titleStr,viewTitleStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //示例变量初始化
        type=[[NSString alloc]init];
        boardName=[[NSString alloc]init];
        articleid=[[NSString alloc]init];
        titleParam=[[NSString alloc]init];
        content=[[NSString alloc]init];
        attach=[[NSData alloc]init];
        rawcontent=[[NSString alloc]init];
        titleStr=[[NSString alloc]init];
        
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
    loadingHud.labelText=@"文章发表中..";
    
    //初始化completedHud
    completedHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:completedHud];
    completedHud.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    completedHud.mode=MBProgressHUDModeCustomView;
    completedHud.delegate=self;
    completedHud.labelText=@"发表成功啦！";
    
    
    [self.isAttachMark setHidden:YES];

    
    //viewTitle:
    self.viewTitle.text=viewTitleStr;
    
    // title:
    self.titleTextField.text=titleStr;
    self.contentTextView.text=[NSString stringWithFormat:@"\n\n-------\n来自xARGO（逸仙时空iOS客户端）\n\n%@",rawcontent];
    //定义contentTextView边框
    self.contentTextView.layer.borderColor=[UIColor blackColor].CGColor;
    self.contentTextView.layer.borderWidth =1.0;
    
    //定义loginAlert边框
    self.loginAlert.layer.borderColor=[UIColor blackColor].CGColor;
    self.loginAlert.layer.borderWidth=1.0;
    
    //添加观察者,以便接收从loginView中过来的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInfoView) name:@"ReloadAddPostView" object:nil];
    //加载数据：
    [self loadInfoView];
}

//判断是否加载contentTextView、loginAlert和loginBtn:
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


- (IBAction)cancel_Click:(id)sender
{
    
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)exit {
    //关闭登录页面
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPost_Click:(id)sender
{
    titleParam=self.titleTextField.text;
    
    content=self.contentTextView.text;
    
    if ([Config Instance].isLogin==NO) {
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"未登录" message:@"登录后才能发表文章" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
        
    }else if ([Config Instance].isLogin==YES){
        
        [loadingHud show:YES];
        
        if (!attach) {
            
            NSDictionary *param=@{@"type": type,@"boardname":boardName,@"title":titleParam,@"content":content,@"articleid":articleid};
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/post/add";
            
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
                    //停留2秒后消失
                    [completedHud hide:YES afterDelay:1.0];
                    [self performSelector:@selector(exit) withObject:nil afterDelay:1.0];
                    
                }else{
                    
                    [loadingHud hide:YES afterDelay:0];
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"发表失败啦" message:@"可重新登录后试试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    [alertView show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [loadingHud hide:YES afterDelay:0];
                
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"发表失败啦" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];
                
            }];

        }else{
            
            NSDictionary *param=@{@"type": type,@"boardname":boardName,@"title":titleParam,@"content":content,@"articleid":articleid};
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/post/add";
            
            [[AFHTTPRequestOperationManager manager]POST:urlString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:attach name:@"attach" fileName:@"attach" mimeType:@"image/jpeg"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *requestTmp = [NSString stringWithString:operation.responseString];
                
                NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                //系统自带JSON解析：
                NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                //NSLog(@"login_resultDict------------------>%@",resultDict);
                int success=[[resultDict objectForKey:@"success"]intValue];
                if (success==1) {
                    
                    //马上隐藏loadingHud:
                    [loadingHud hide:YES afterDelay:0];
                    //提示发送成功:
                    [completedHud show:YES];
                    //停留2秒后消失
                    [completedHud hide:YES afterDelay:1.0];
                    [self performSelector:@selector(exit) withObject:nil afterDelay:1.0];
                    
                }else{
                    
                    [loadingHud hide:YES afterDelay:0];
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"发表失败啦" message:@"可重新登录后试试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    [alertView show];
                }

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [loadingHud hide:YES afterDelay:0];
                
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"发表失败啦" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alertView show];

            }];
            
        }
        
        
    }
}



- (IBAction)takePicture:(id)sender {
    
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }else{
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    attach=UIImageJPEGRepresentation(image, 1);
    
    [self.isAttachMark setHidden:NO];
    
    image=nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//输入之后,点击屏幕其他地方键盘消失
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.titleTextField isFirstResponder] && [touch view] !=self.titleTextField)
    {
        [self.titleTextField resignFirstResponder];
    }
    if ([self.contentTextView isFirstResponder] && [touch view] !=self.contentTextView) {
        [self.contentTextView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
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
