//
//  MyCollectionViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "LoadingCell.h"
#import "AFNetworking.h"

@interface MyCollectionViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
{
    LoadingCell *loadingCell;
    //针对上次更新时间设置变量存储：
    NSString *lastUpdated;
    NSDateFormatter * dateFormatter;
}

@property (nonatomic, strong) NSMutableArray *favariteBoards;

-(void)loadData;


@end
