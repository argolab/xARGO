//
//  SendMailViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface SendMailViewController : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *loadingHud;
    MBProgressHUD *completedHud;
}

//有可能需要从其他地方传递过来的参数：
@property (nonatomic, strong)NSString *mailTitleStr;
@property (nonatomic, strong)NSString *contentStr;
@property (nonatomic, strong)NSString *receiverStr;
//@property (nonatomic, strong)NSString *articleidStr;




@property (strong, nonatomic) IBOutlet UITextField *receiverTextField;


@property (strong, nonatomic) IBOutlet UITextField *mailTitleTextField;


@property (strong, nonatomic) IBOutlet UITextView *contentTextView;

//发送和取消按钮：

- (IBAction)click_sendBtn:(id)sender;

- (IBAction)click_cancelBtn:(id)sender;



//登录提示：

@property (strong, nonatomic) IBOutlet UILabel *loginAlert;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;





@end
