//
//  BoardListViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "BoardListViewController.h"
#import "PostListViewController.h"

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
    // Do any additional setup after loading the view.
    //NSLog(@"boards-------------->%@",boards);
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boardListCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"boardListCell"];
    }
    
    NSString *titleStr=@"loading..";
    NSString *total_todayStr=@"loading..";
    NSString *str_BM=@"loading..";
    
    if (boards&&[boards count]) {
        
        titleStr=[NSString stringWithFormat:@"%@（%@）",[[boards objectAtIndex:indexPath.row]objectForKey:@"title"],[[boards objectAtIndex:indexPath.row]objectForKey:@"boardname"]];
        
        total_todayStr=[NSString stringWithFormat:@"%@",[[boards objectAtIndex:indexPath.row]objectForKey:@"total_today"]];
        
        //这里的BM类型是字符串类型，而收藏那里取出来的是数组，要注意区分
        str_BM=[NSString stringWithFormat:@"%@",[[boards objectAtIndex:indexPath.row]objectForKey:@"BM"]];
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
        destViewController.boardName=[[boards objectAtIndex:indexPath.row]objectForKey:@"boardname"];
        //destViewController.total_topicNum=[[boards[indexPath.row]objectForKey:@"total_topic"]integerValue];
        destViewController.boardTitle=[NSString stringWithFormat:@"%@",[boards[indexPath.row]objectForKey:@"title"]];

        
        destViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
    }
}


@end
