//
//  AllBoardsViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-18.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "AllBoardsViewController.h"
#import "BoardListViewController.h"


@interface AllBoardsViewController ()

@end

@implementation AllBoardsViewController


//load the data, and to see if everything went ok.
-(void)loadData
{
    [loadingCell loading];
    [self performSelector:@selector(fetchServerData) withObject:nil afterDelay:0];
}

-(void)fetchServerData
{
    NSURL *url=[NSURL URLWithString:@"http://argo.sysu.edu.cn/ajax/board/alls"];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"sucesss:%@",operation.responseObject);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"resultDict------------------>%@",resultDict);
        NSDictionary *data=[resultDict objectForKey:@"data"];
        //NSLog(@"data------------------>%@",data);
        all=[data objectForKey:@"all"];
        //缓存all:
        [[DataCache Instance]saveBoardsAllDataCache:all];
        for (NSDictionary *allInfo in all)
        {
            [sectionNames addObject:[allInfo objectForKey:@"secname"]];
            [allBoards addObject:[allInfo objectForKey:@"boards"]];
            
        }
        
        //释放掉已经用过的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        data=nil;
        all=nil;
        
        [self.tableView reloadData];
        [loadingCell normal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Failure: %@", operation.error);
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
    [operation start];

}


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
    //初始化实例变量
    sectionNames=[[NSMutableArray alloc]init];
    allBoards=[[NSMutableArray alloc]init];
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"" andLoadingStr:@"数据加载中" andStartViewStr:@"数据加载中"];
    all=[[NSArray alloc]init];
    
    
    
    //如果缓存了数据，则读取缓存数据,否则，加载服务器数据：
    if ([[DataCache Instance]getBoardsAllDataCache]) {
        
        all=[[DataCache Instance]getBoardsAllDataCache];
        
        for (NSDictionary *allInfo in all)
        {
            [sectionNames addObject:[allInfo objectForKey:@"secname"]];
            [allBoards addObject:[allInfo objectForKey:@"boards"]];
        }

    }else{
        
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];
        
    }
    
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
    [sectionNames removeAllObjects];
    [allBoards removeAllObjects];
    
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
    return [sectionNames count]+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sectionListCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionListCell"];
    }
    if (indexPath.row <[sectionNames count]) {
        
        NSString *str=@"loading..";
        
        if (sectionNames&&[sectionNames count]) {
            str=[NSString stringWithFormat:@"%@",sectionNames[indexPath.row]];
        }
        
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
        if (allBoards&&[allBoards count]) {
            destViewController.boards=allBoards[indexPath.row];
            destViewController.navigationItem.title=[NSString stringWithFormat:@"%@",sectionNames[indexPath.row]];
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
