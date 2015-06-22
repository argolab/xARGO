//
//  BoardListViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "AllBoardListViewController.h"

@interface BoardListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *boards;
@property (nonatomic, strong) NSDictionary *sectionDict;

@property (nonatomic, strong) LoadingCell *loadingCell;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
