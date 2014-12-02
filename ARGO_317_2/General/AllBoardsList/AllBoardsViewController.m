//
//  AllBoardsViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-18.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "AllBoardsViewController.h"
#import "BoardListViewController.h"
#import "DataManager.h"


@interface AllBoardsViewController ()

@end

@implementation AllBoardsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//load the data, and to see if everything went ok.
-(void)loadData
{
    [loadingCell loading];
    
    [[DataManager manager]getAllSections: ^(NSDictionary *resultDict){
        sections=[resultDict objectForKey:@"data"];
        
        [self.tableView reloadData];
        [loadingCell normal];
        
    } failure:^(NSString *data, NSError *error) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化实例变量
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"" andLoadingStr:@"数据加载中" andStartViewStr:@"数据加载中"];

    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];
    
    //下拉刷新
    [self pullDownToRefresh];
}


//下拉刷新
- (void)pullDownToRefresh
{
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
    sections = nil;
    
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
    return [sections count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sectionListCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionListCell"];
    }
    if (indexPath.row <[sections count]) {
        
        NSString *str=@"loading..";
        str=[NSString stringWithFormat:@"%@",[sections[indexPath.row] objectForKey:@"secname"]];
        
        cell.textLabel.text=str;
        
        str=nil;
        
        return cell;
        
    }else{
        return loadingCell.cell;
    }
}

#pragma mark - Navigation

// 传递数据至BoardlistViewController
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBoardlistViewController"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BoardListViewController *destViewController = segue.destinationViewController;
        if (sections&&[sections count]) {
            destViewController.sectionDict=sections[indexPath.row];
            destViewController.navigationItem.title=[NSString stringWithFormat:@"%@",[sections[indexPath.row] objectForKey:@"secname"]];
        }else{
            NSDictionary *nullDict=@{@"title": @"error",@"boardname":@"",@"total_today":@"",@"BM":@""};
            destViewController.boards=@[nullDict];
            destViewController.navigationItem.title=@"请退回重新进入";
        }
        destViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
    }
}

@end
