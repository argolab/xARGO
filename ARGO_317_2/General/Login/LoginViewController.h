//
//  LoginViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Config.h"
//#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface LoginViewController : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *loadingHud;
    MBProgressHUD *completedHud;
}


@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

- (IBAction)usernameReturn:(id)sender;

- (IBAction)passwordReturn:(id)sender;

- (IBAction)passwordTyping:(id)sender;

- (IBAction)click_Login:(id)sender;

- (IBAction)click_cancel:(id)sender;


- (void)login;

@end
