//
//  ARGOAppDelegate.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//


#import "MEMenuViewController.h"

@interface MEMenuViewController ()

@end

@implementation MEMenuViewController

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue { }



- (void)viewDidLoad{
    
    //添加观察者,以便接收从loginView中过来的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewMailAlert) name:@"haveNewMailAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNewMailAlert) name:@"noNewMailAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewMessageAlert) name:@"haveNewMessageAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNewMessageAlert) name:@"noNewMessageAlert" object:nil];
    
    
    //增加计时器，每三分钟获取一次数据，提醒用户有无新消息
    //NSTimer *timer = [NSTimer timerWithTimeInterval:180.0  target:self selector:@selector(messageAlert) userInfo:nil repeats:YES];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(messageAlert) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}


-(void)messageAlert{
    
    NSString *urlString=[NSString stringWithFormat:@"http://argo.sysu.edu.cn/ajax/mail/check"];
    NSURL *url=[NSURL URLWithString:urlString];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //NSLog(urlString);
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"success------------------------>%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"resultDict------------------>%@",resultDict);
        
        //data是一个字符串，第一个字符如果是1，表示有新的邮件;第二个字符如果是1，表示有新的消息;第三个字符如果是1，表示收藏夹的看板有新的帖子
        
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            int data=[[resultDict objectForKey:@"data"]intValue];
            if (data==1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMailAlert" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMessageAlert" object:nil];
                
            }else if (data==10){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMailAlert" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageAlert" object:nil];
            }else if (data==11){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMailAlert" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageAlert" object:nil];
            }else if (data==100){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMailAlert" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMessageAlert" object:nil];
            }else if (data==101){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMailAlert" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMessageAlert" object:nil];
                
            }else if (data==111){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageAlert" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMailAlert" object:nil];
            }
            
        }
        
    } failure:nil];
    [operation start];
    
    
    
}





-(void)haveNewMailAlert{
    //_mail.text=@"信箱（有新信件）";
    _mail.text=@"信箱";
    //_mail.textColor=[UIColor orangeColor];
}

-(void)noNewMailAlert{
    _mail.text=@"信箱";
}

-(void)haveNewMessageAlert{
    _message.text=@"提醒（有新消息）";
    //_message.textColor=[UIColor orangeColor];
}

-(void)noNewMessageAlert{
    _message.text=@"提醒";
}



@end
