//
//  PostListViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-27.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//
#define REFRESH_HEADER_HEIGHT 52.0f
#define pageSize 20

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
#import "SINavigationMenuView.h"
#import "Config.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"


@interface TopicListViewController : UIViewController<SINavigationMenuDelegate,MBProgressHUDDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSString *boardName;
    NSInteger currPage;
    NSInteger total_topicNum;
    MBProgressHUD *loadingHud;
    //针对上次更新时间设置变量存储：
    NSString *lastUpdated;
    NSDateFormatter * dateFormatter;
    
    //数据是否准备好了,用来控制数据还没准备好又再上拉加载：
    __block BOOL isDataReady;

}

@property (nonatomic, strong) NSString *boardName;
@property (nonatomic, strong) NSMutableArray *postListPage;
@property (nonatomic, strong) NSMutableArray *postList;
@property (nonatomic, strong) LoadingCell *loadingCell;
@property (nonatomic) NSInteger total_topicNum;

@property (nonatomic, strong) NSString *boardTitle;

@property (strong, nonatomic) IBOutlet UITableView *_tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;


//加载服务器数据
- (void)loadData;
- (void)fetchServerDataFromStartNum:(NSInteger)startNum;
- (void)fetchTotal_topicNumWithBoardName:(NSString *)boardname;//获取Total_topicNum参数

//下拉刷新
- (void)pullDownToRefresh;


@end
