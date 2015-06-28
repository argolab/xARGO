//
//  ARGOAppDelegate.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//


#import "MEMenuViewController.h"
#import "Config.h"

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
    
    
    //增加计时器，每一分钟获取一次数据，提醒用户有无新消息
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(messageAlert) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}


-(void)messageAlert{
    if (![Config Instance].isLogin) {
        // return without trying in case that User is not login.
        return;
    }
    [[DataManager manager] checkMail:^(NSDictionary *resultDict) {
        //data是一个字符串，第一个字符如果是1，表示有新的邮件;第二个字符如果是1，表示有新的消息;第三个字符如果是1，表示收藏夹的看板有新的帖子
        unsigned long data= strtoul([ [resultDict objectForKey:@"data"] UTF8String], NULL, 2);
        if (data & 0b1) {
            // Notify favourate. Ignore currently.
        }
        if (data & 0b10) {
            // Notify new message
            [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMessageAlert" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMessageAlert" object:nil];
        }
        
        if (data & 0b100) {
            // Notify new mail
            [[NSNotificationCenter defaultCenter] postNotificationName:@"haveNewMailAlert" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMailAlert" object:nil];
        }
    } failure:^(NSString *data, NSError *error) {
        NSLog(@"Failed when checking mail. Reason=%@", error);
    }];
    
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
