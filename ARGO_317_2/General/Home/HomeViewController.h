//
//  HomeViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-18.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
//#import "Config.h"


@interface HomeViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>{
    
    NSInteger currPage;//用于计算cursor参数
    LoadingCell *loadingCell;
    NSArray *freshTopicsPerCursor;
    //针对上次更新时间设置变量存储：
    NSString *lastUpdated;
    NSDateFormatter * dateFormatter;
}

@property (nonatomic, strong) NSMutableArray *topTenTopics;
@property (nonatomic, strong) NSMutableArray *freshTopics;

-(void)loadData;
-(void)fetchTopTensDataFromServer;
-(void)fetchFreshTopicFromeServer;

//下拉刷新
- (void)pullDownToRefresh;


@end
