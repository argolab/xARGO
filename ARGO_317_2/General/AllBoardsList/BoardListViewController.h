//
//  BoardListViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "AllBoardsViewController.h"

@interface BoardListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *boards;
    NSInteger *total_topicNumber;
}

@property (nonatomic, strong) NSArray *boards;



@end
