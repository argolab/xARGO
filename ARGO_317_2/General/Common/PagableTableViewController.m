//
//  PagableTableViewController.m
//  xARGO
//
//  Created by exiaomo on 28/6/15.
//  Copyright (c) 2015 490021684@qq.com. All rights reserved.
//

#import "PagableTableViewController.h"

@implementation PagableTableViewController

@synthesize boardName,theTitle;

-(void) viewDidLoad {
    [super viewDidLoad];
    //初始化loadingCell等实例变量：
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"上拉加载更多" andLoadingStr:@"数据加载中.." andStartViewStr:@"可下拉刷新"];
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                 [dateFormatter stringFromDate:[NSDate date]]];
    isDataLoading = NO;
    dataList = [[NSMutableArray alloc]init];
    //下拉刷新列表
    [self initRefreshController];
    [self willLoadTotalNum];
    [self loadTotalNum];
}

-(void) willLoadTotalNum {
    // prepare for loading
    [loadingCell loading];
}

-(void) didLoadTotalNum {
    // Assume that total num and first page are loaded.
    [self loadNextPage];
}

-(void) willLoadNextPage {
    [loadingCell loading];
}

-(void) didLoadNextPage {
    [loadingCell normal];
    if (currentPage*pageSize < totalNum) {
        loadingCell.label.text = [NSString stringWithFormat:@"下面还有%ld项，轻轻上拉继续看",totalNum - currentPage*pageSize];
    } else {
        loadingCell.label.text = NSLocalizedString(@"No more items", @"");
    }

}

- (void)initRefreshController {
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor=[UIColor lightGrayColor];
    refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

//下拉刷新调用的方法
-(void)refreshView:(UIRefreshControl *)refresh {
    if (refresh.refreshing) {
        [refresh endRefreshing];
        if (!isDataLoading) {
            [self clearAndReload];
        }
        //页数重新定位在最前面,清空数组
    }
}

-(void) clearAndReload {
    currentPage = 0;
    totalNum = 0;
    [dataList removeAllObjects];
    [self.tableView reloadData];
    [self willLoadTotalNum];
    [self loadTotalNum];
}

// 将时间戳转为时间,然后再转为可理解的字符串
-(NSString *)timeDescipFrom:(double)timeStr {
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    
    NSDate *theday = [NSDate dateWithTimeIntervalSince1970:timeStr];
    //NSLog(@"theday------------------>%@",theday);
    NSString *str=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:theday]];
    
    return str;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postListCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postListCell"];
    }
    if (indexPath.row <[dataList count]) {
        NSDictionary *cellData = dataList[indexPath.row];
        [self composite:cell at:indexPath with:cellData];
        return cell;
    } else {
        //最后一项，加载更多
        return loadingCell.cell;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataList count] + 1;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //触发上拉加载更多的条件
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0){
        [self willLoadNextPage];
        [self performSelector:@selector(loadNextPage) withObject:nil afterDelay:0];
    }
}

-(void) loadTotalNum {
    // Empty method, which should be overrided by sub-class.
}

-(void) loadNextPage {
    // Empty method, which should be overrided by sub-class.
}

- (void) composite:(UITableViewCell *) cell
                at:(NSIndexPath *) indexPath
              with:(NSDictionary *) data {
    // Empty method, which should be overrided by sub-class.
}

@end
