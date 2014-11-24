//
//  UserQueryViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-19.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface UserQueryViewController : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *loadingHud;
}


@property (nonatomic, strong) NSString *userid;



@property (strong, nonatomic) IBOutlet UILabel *userInfoTextField;


@end
