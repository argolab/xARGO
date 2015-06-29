//
//  PostViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-26.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//
#define REFRESH_HEADER_HEIGHT 52.0f

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
#import "MBProgressHUD.h"

@interface PostListViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate> {
    NSString *boardName;
    NSString *fileName;
    LoadingCell *loadingCell;
    //针对上次更新时间设置变量存储：
    NSString *lastUpdated;
    NSDateFormatter * dateFormatter;
    //页数计数：
    NSInteger currPage;
    //是否加载完毕
    __block BOOL isAllDataFinished;
    //数据是否准备好了,用来控制数据还没准备好又再上拉加载：
    __block BOOL isDataReady;
}
@property (nonatomic, strong) NSString *boardName;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSMutableArray *postTopicList;//里面的元素是filename字符串
@property (nonatomic, strong) NSMutableArray *postList;
@property (nonatomic, strong) NSString *hintText;
@property (nonatomic) NSInteger hintIndex;

@end
