//
//  BoardListViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "BoardListViewController.h"
#import "TopicListViewController.h"
#import "DataManager.h"

@interface BoardListViewController ()

@end

@implementation BoardListViewController
@synthesize boards,loadingCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadData {
    [loadingCell loading];
    if (self.sectionDict) {
        NSString *seccode=[self.sectionDict objectForKey:@"seccode"];
        [[DataManager manager] getBoardsBySection:seccode success:^(NSDictionary *data){
            // Sorted by english name, i.e. the field of filename.
            self.boards=[[data objectForKey:@"data"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 objectForKey:@"filename"] caseInsensitiveCompare:[obj2 objectForKey:@"filename"]];
            }];
            [self.tableView reloadData];
            [loadingCell normal];
            
        } failure: ^(NSString *data, NSError *error){
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"" andLoadingStr:@"数据加载中.." andStartViewStr:@"数据加载中"];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];
    [self pullDownToRefresh];

}
//下拉刷新
- (void)pullDownToRefresh {
    UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
    refresh.tintColor=[UIColor lightGrayColor];
    refresh.attributedTitle=[[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
}


//下拉刷新调用的方法
-(void)handleData
{
    [self loadData];
    [self.refreshControl endRefreshing];
}

//下拉刷新调用的方法
-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"数据更新中..."];
        //页数重新定位在最前面,清空数组
        [self clear];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:1.2];
    }
}

- (void)clear
{
    boards = nil;
    [loadingCell loading];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [boards count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (boards && indexPath.row < [boards count]) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"boardListCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"boardListCell"];
        }

        NSString *titleStr=@"loading..";
        NSString *total_todayStr=@"loading..";
        NSString *str_BM=@"loading..";
        NSString *numTotalPost=@"loading..";
        BOOL hasUnread=NO;
        
        NSDictionary *curBoard=[boards objectAtIndex:indexPath.row];
        
        titleStr=[NSString stringWithFormat:@"%@（%@）",[curBoard objectForKey:@"title"],[curBoard objectForKey:@"filename"]];
        
        total_todayStr=[NSString stringWithFormat:@"%@",[curBoard objectForKey:@"total_today"]];
        
        //这里的BM类型是字符串类型，而收藏那里取出来的是数组，要注意区分
        //改为用sec api获取数据时这里的BM也是数组了
        NSArray *array = [curBoard objectForKey:@"BM"];
        str_BM = (array&&array.count>0)? array[0]:@"暂无版主";

        NSString *unreadFlag = [curBoard objectForKey:@"unread"];
        hasUnread = (unreadFlag && unreadFlag.length >0);
        
        numTotalPost = [curBoard objectForKey:@"total"];
        
        ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
        
        ((UILabel *)[cell.contentView viewWithTag:2]).text=total_todayStr;
        
        //这里的BM类型是字符串类型，而收藏那里取出来的是数组，要注意区分
        ((UILabel *)[cell.contentView viewWithTag:3]).text=str_BM;
        
        // Disable the unread indication temporarily
        [[cell.contentView viewWithTag:4] setHidden:true];
        
        // Disable the total number of topics temporarily
        [[cell.contentView viewWithTag:5] setHidden:true];
        
        titleStr=nil;
        total_todayStr=nil;
        str_BM=nil;
        
        return cell;

    } else {
        // NSLog(@"returning LoadingCell.");
        return loadingCell.cell;
    }
}

#pragma mark - Navigation
//传递数据（boardname)至帖子列表
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostListFromBoardList"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //传递参数
        TopicListViewController *destViewController = segue.destinationViewController;
        destViewController.boardName=[[boards objectAtIndex:indexPath.row]objectForKey:@"filename"];

        destViewController.boardTitle=[NSString stringWithFormat:@"%@",[boards[indexPath.row]objectForKey:@"title"]];
        // NSLog(@"%@",[boards description]);

        destViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
    }
}


@end
