//
//  MailListViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#define REFRESH_HEADER_HEIGHT 52.0f


#import <UIKit/UIKit.h>
#import "Config.h"
#import "LoadingCell.h"
#import "AFNetworking.h"

@interface MailListViewController : UITableViewController
{
    NSInteger currPage;
    NSInteger totalMail;
    LoadingCell *loadingCell;
    //针对上次更新时间设置变量存储：
    NSString *lastUpdated;
    NSDateFormatter * dateFormatter;

}

@property (nonatomic, strong) NSMutableArray *mailList;
@property (nonatomic, strong) NSMutableArray *mailListPage;


-(void)loadData;
-(void)fetchDataFromServerWithStartNum:(NSInteger)startNum;
-(void)fetchMailBoxInfoFromServer;



@end
