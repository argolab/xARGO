//
//  AllBoardsViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-18.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
#import "DataCache.h"
#import "AFNetworking.h"

@interface AllBoardsViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *sectionNames;
    NSMutableArray *allBoards;
    LoadingCell *loadingCell;
    NSArray *all;
}


-(void)loadData;
-(void)fetchServerData;


@end
