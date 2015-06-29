//
//  PagableTableViewController.h
//  xARGO
//
//  Created by exiaomo on 28/6/15.
//  Copyright (c) 2015 490021684@qq.com. All rights reserved.
//
#define REFRESH_HEADER_HEIGHT 52.0f
#define pageSize 20

#import <UIKit/UIKit.h>
#import "LoadingCell.h"
#import "MBProgressHUD.h"

@interface PagableTableViewController : UITableViewController <MBProgressHUDDelegate> {
    NSDateFormatter * dateFormatter;
    NSString *lastUpdated;
    NSMutableArray *dataList;
    LoadingCell *loadingCell;
    NSInteger totalNum;
    NSInteger currentPage;
    bool isDataLoading;
    UIRefreshControl* refreshControl;
}

@property (nonatomic, strong) NSString *boardName;
@property (nonatomic, strong) NSString *theTitle;

// point-cut methods
- (void)willLoadTotalNum;
// point-cut methods
- (void)didLoadTotalNum;
// point-cut methods
- (void)willLoadNextPage;
// point-cut methods
- (void)didLoadNextPage;

- (void)clearAndReload;

// actual loading logic, which should be override by sub-class
- (void)loadTotalNum;
// actual loading logic, which should be override by sub-class
- (void)loadNextPage;
// actual composition logic, which should be override by sub-class
- (void) composite:(UITableViewCell *) cell at:(NSIndexPath *) indexPath
              with:(NSDictionary *) data;

- (NSString *)timeDescipFrom:(double)timeStr;

@end
