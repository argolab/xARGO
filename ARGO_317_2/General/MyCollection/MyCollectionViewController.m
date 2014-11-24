//
//  MyCollectionViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-24.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "PostListViewController.h"
#import "LoginViewController.h"

@interface MyCollectionViewController ()

@end

@implementation MyCollectionViewController
@synthesize favariteBoards;

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
    favariteBoards=[[NSMutableArray alloc]init];
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"" andLoadingStr:@"数据加载中" andStartViewStr:@""];
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                 [dateFormatter stringFromDate:[NSDate date]]];
    //设置分隔线样式
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;

    
    if ([Config Instance].isLogin==YES) {
        NSLog(@"[Config Instance].isLogin-------->1");
        [loadingCell loading];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
        
        
    }else if ([Config Instance].isLogin==NO){
        NSLog(@"[Config Instance].isLogin-------->0");
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"未登录" message:@"登录后才能查看你的收藏版面" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];

        //LoginViewController *loginView=[[LoginViewController alloc]init];
        //[self presentViewController:loginView animated:YES completion:nil];
        //[[self navigationController]pushViewController:loginView animated:YES];

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
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        //页数重新定位在最前面,清空数组
        [self clear];
        [self performSelector:@selector(handleData) withObject:nil afterDelay:1.2];
    }
}

- (void)clear
{
    [favariteBoards removeAllObjects];
    
    [loadingCell loading];
    
    [self.tableView reloadData];
}

- (void)loadData
{
    if ([Config Instance].isLogin==YES) {
        //记录数据加载时间：
        lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                     [dateFormatter stringFromDate:[NSDate date]]];
        NSString *urlString=@"http://argo.sysu.edu.cn/ajax/user/fav";
        [[AFHTTPRequestOperationManager manager] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"operation.responseObject---------------->%@",operation.responseObject);
            NSString *requestTmp = [NSString stringWithString:operation.responseString];
            NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
            //系统自带JSON解析：
            NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
            //NSLog(@"login_resultDict------------------>%@",resultDict);
            int success=[[resultDict objectForKey:@"success"]intValue];
            if (success==1) {
                //favariteBoards=[[NSArray alloc]init];
                NSArray *data=[resultDict objectForKey:@"data"];
                
                //NSLog(@"data-------------->%@",data);
                for (NSDictionary *board in data) {
                    if (board&&[board isKindOfClass:[NSDictionary class]]) {
                        [favariteBoards addObject:board];
                    }
                }
                //NSLog(@"favariteBoards------------------>%@",favariteBoards);
                [self.tableView reloadData];
                [loadingCell normal];
                
            }else{
                //判断success的值，如果未返回一则打开登录页
                //LoginViewController *loginView=[[LoginViewController alloc]init];
                //[self presentViewController:loginView animated:YES completion:nil];
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"加载失败" message:@"可重新登录后试试" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
            //设置分隔线正常
            self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

            
            //释放掉用过的变量：
            requestTmp=nil;
            resData=nil;
            resultDict=nil;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //设置分隔线正常
            self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"登录失败" message:[error localizedDescription] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }];
    
    }else if ([Config Instance].isLogin==NO){
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"未登录" message:@"登录后才能查看你的收藏版面" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }


    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favariteBoards count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <[favariteBoards count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favariteBoardsCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"favariteBoardsCell"];
        }
        NSString *titleStr=@"loading";
        NSString *total_todayStr=@"loading";
        NSString *str_BM=@"loading";
        
        if (favariteBoards&&[favariteBoards count]) {
            titleStr=[NSString stringWithFormat:@"%@（%@）",[favariteBoards[indexPath.row] objectForKey:@"title"],[favariteBoards[indexPath.row] objectForKey:@"boardname"]];

            total_todayStr=[NSString stringWithFormat:@"%@",[favariteBoards[indexPath.row]objectForKey:@"total_today"]];

            str_BM=[[favariteBoards[indexPath.row]objectForKey:@"BM"] componentsJoinedByString:@","];

        }
        
        //NSLog(@"favariteBoards--------------->%@",favariteBoards);
        ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
        
        ((UILabel *)[cell.contentView viewWithTag:2]).text=total_todayStr;
        
        //这里的BM类型与boarlist中得类型不一样，是数组类型。
        ((UILabel *)[cell.contentView viewWithTag:3]).text=str_BM;
        
        titleStr=nil;
        total_todayStr=nil;
        str_BM=nil;
        
        return cell;
        
    }else{
        return loadingCell.cell;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPostListViewFromMyCollectionView"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        PostListViewController *destViewController = segue.destinationViewController;
        
        if (favariteBoards&&[favariteBoards count]) {
            destViewController.boardName=[favariteBoards[indexPath.row]objectForKey:@"boardname"];
            
            destViewController.boardTitle=[NSString stringWithFormat:@"%@",[favariteBoards[indexPath.row] objectForKey:@"title"]];
            //destViewController.navigationItem.title=[favariteBoards[indexPath.row]objectForKey:@"title"];
        }else{
            destViewController.boardName=@"";
            destViewController.boardTitle=@"请退回重新进入";
        }
        
        destViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
    }

    
}


@end
