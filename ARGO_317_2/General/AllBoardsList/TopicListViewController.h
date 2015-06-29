//
//  PostListViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-27.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
#import "SINavigationMenuView.h"
#import "Config.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "PagableTableViewController.h"


@interface TopicListViewController : PagableTableViewController<SINavigationMenuDelegate> {
    MBProgressHUD *loadingHud;
}

@end
