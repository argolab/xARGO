//
//  MailDetailViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface MailDetailViewController : UITableViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *loadingHud;
}


@property (nonatomic) NSInteger mailIndex;
@property (nonatomic, strong) NSDictionary *mailDetail;

-(void)fetchMailDetailFromServerWith:(NSInteger)index;


@property (strong, nonatomic) IBOutlet UILabel *mailTitle;

@property (strong, nonatomic) IBOutlet UILabel *mailContent;


@end
