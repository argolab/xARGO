//
//  LoginGuideViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface LoginGuideViewController : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *loadingHud;
}

- (IBAction)click_logout:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *userInfoTextField;

@property (strong, nonatomic) IBOutlet UILabel *loginGuideTextField;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong, nonatomic) IBOutlet UIButton *logoutBtn;



- (void)loadInfoView;

- (void)loadUserInfo;



@end
