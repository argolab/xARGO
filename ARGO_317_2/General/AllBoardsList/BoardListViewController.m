//
//  BoardListViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "BoardListViewController.h"
#import "PostListViewController.h"
#import "DataManager.h"
#import "TDBadgedCell.h"

@interface BoardListViewController ()

@end

@implementation BoardListViewController
@synthesize boards;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Load sections. TODO: use pull&refresh pattern here as loading is asynch.
    if (self.sectionDict) {
        NSString *seccode=[self.sectionDict objectForKey:@"seccode"];
        [[DataManager manager] getBoardsBySection:seccode success:^(NSDictionary *data){
            // Sorted by english name, i.e. the field of filename.
            self.boards=[[data objectForKey:@"data"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj1 objectForKey:@"filename"] caseInsensitiveCompare:[obj2 objectForKey:@"filename"]];
            }];
        } failure: ^(NSString *data, NSError *error){
            //TODO: handle error.
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [boards count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:@"boardListCell"];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"boardListCell"];
    }

    NSString *titleStr=@"loading..";
    NSString *total_todayStr=@"loading..";
    NSString *str_BM=@"loading..";
    
    if (boards && [boards count]) {
        NSDictionary *curBoard=[boards objectAtIndex:indexPath.row];
        
        titleStr=[NSString stringWithFormat:@"%@（%@）",[curBoard objectForKey:@"title"],[curBoard objectForKey:@"filename"]];
        
        total_todayStr=[NSString stringWithFormat:@"%@",[curBoard objectForKey:@"total_today"]];
        
        //这里的BM类型是字符串类型，而收藏那里取出来的是数组，要注意区分
        //改为用sec api获取数据时这里的BM也是数组了
        NSArray *array = [curBoard objectForKey:@"BM"];
        str_BM = (array&&array.count>0)? array[0]:@"暂无版主";

        NSString *unreadFlag = [curBoard objectForKey:@"unread"];
        cell.badgeString = [curBoard objectForKey:@"total"];
        cell.badgeColor = (unreadFlag && unreadFlag.length >0)?[UIColor colorWithRed:0 green:0.478 blue:1 alpha:1.0] :[UIColor grayColor];
    }
    
    ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
    
    ((UILabel *)[cell.contentView viewWithTag:2]).text=total_todayStr;
    
    //这里的BM类型是字符串类型，而收藏那里取出来的是数组，要注意区分
    ((UILabel *)[cell.contentView viewWithTag:3]).text=str_BM;
    
    titleStr=nil;
    total_todayStr=nil;
    str_BM=nil;
    
    return cell;
}

#pragma mark - Navigation
//传递数据（boardname)至帖子列表
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostListFromBoardList"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //传递参数
        PostListViewController *destViewController = segue.destinationViewController;
        destViewController.boardName=[[boards objectAtIndex:indexPath.row]objectForKey:@"filename"];

        destViewController.boardTitle=[NSString stringWithFormat:@"%@",[boards[indexPath.row]objectForKey:@"title"]];

        destViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
    }
}


@end
