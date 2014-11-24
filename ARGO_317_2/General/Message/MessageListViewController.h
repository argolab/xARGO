//
//  MessageListViewController.h
//  xARGO
//
//  Created by 490021684@qq.com on 14-10-12.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
#import "Config.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface MessageListViewController : UIViewController<MBProgressHUDDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInteger currPageStartNum;
    NSInteger countWhenStartNumIsOne;
    MBProgressHUD *loadingHud;
    //针对上次更新时间设置变量存储：
    NSString *lastUpdated;
    NSDateFormatter * dateFormatter;
    //数据是否准备好了,用来控制数据还没准备好又再上拉加载：
    __block BOOL isDataReady;
    
}


@property (nonatomic, strong) NSMutableArray *postListPage;
@property (nonatomic, strong) NSMutableArray *postList;
@property (nonatomic, strong) LoadingCell *loadingCell;
@property (strong, nonatomic) UIRefreshControl *refreshControl;





@property (strong, nonatomic) IBOutlet UITableView *_tableView;


//加载服务器数据
- (void)loadData;
- (void)fetchServerDataFromStartNum:(NSInteger)startNum;

//下拉刷新
- (void)pullDownToRefresh;




@end
