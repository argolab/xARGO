//
//  MailListViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "MailListViewController.h"
#import "MailDetailViewController.h"

@interface MailListViewController ()

@end

@implementation MailListViewController
@synthesize mailList,mailListPage;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //通知取消“新信件通知”
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMailAlert" object:nil];
    
    //初始化实例变量
    currPage=0;
    totalMail=0;
    mailList=[[NSMutableArray alloc]init];
    mailListPage=[[NSMutableArray alloc]initWithCapacity:20];
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"" andLoadingStr:@"数据加载中.." andStartViewStr:@"可下拉刷新.."];
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                 [dateFormatter stringFromDate:[NSDate date]]];
    //设置分隔线样式
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;
    

    
    
    if ([Config Instance].isLogin==YES) {
        NSLog(@"[Config Instance].isLogin-------->1");
        [loadingCell startView];
        [self performSelector:@selector(fetchMailBoxInfoFromServer) withObject:nil afterDelay:0];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
        
        
    }else if ([Config Instance].isLogin==NO){
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        NSLog(@"[Config Instance].isLogin-------->0");
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"未登录" message:@"登录后才能查看你的信箱" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    //下拉刷新列表
    [self pullDownToRefresh];

}

-(void)loadData
{
    
    if ([Config Instance].isLogin==YES) {
        
        currPage++;
        NSInteger startNum=totalMail-(currPage-1)*20;
        NSLog(@"totalMail------------------>%ld",(long)totalMail);

        
        //记录数据加载时间：
        lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                     [dateFormatter stringFromDate:[NSDate date]]];
        if (totalMail==0) {
            //[loadingCell loading];
            //startNum=0;
            //[self fetchDataFromServerWithStartNum:startNum];
        }else if(totalMail>currPage*20){
            [loadingCell loading];
            startNum=totalMail-currPage*20+1;
            [self fetchDataFromServerWithStartNum:startNum];
            
        }else if(totalMail<=currPage*20&&totalMail>(currPage-1)*20){
            [loadingCell loading];
            startNum=1;
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/mail/list";
            
            NSNumber *startNumber=[NSNumber numberWithInteger:startNum];
            
            NSDictionary *param=@{@"start": startNumber};
            
            [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"operation.responseObject---------------->%@",operation.responseObject);
                NSString *requestTmp = [NSString stringWithString:operation.responseString];
                NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                //系统自带JSON解析：
                NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                //NSLog(@"mailList_resultDict------------------>%@",resultDict);
                int success=[[resultDict objectForKey:@"success"]intValue];
                if (success==1) {
                    
                    mailListPage=[resultDict objectForKey:@"data"];
                    
                    //从最近的开始读起：
                    for (NSInteger i=totalMail-(currPage-1)*20-1; i>=0; i--) {
                        if (mailListPage[i]&&[mailListPage[i] isKindOfClass:[NSDictionary class]]) {
                            [mailList addObject:mailListPage[i]];
                        }
                    }
                    
                    [self.tableView reloadData];
                    //[loadingCell normal];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
                    lastUpdated=[NSString stringWithFormat:@"更新时间%@",
                                 [formatter stringFromDate:[NSDate date]]];
                    [loadingCell normal];
                    loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
                    formatter=nil;

                    
                }else{
                    //判断success的值，如果未返回一则打开登录页
                    //[loadingCell normal];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
                    lastUpdated=[NSString stringWithFormat:@"更新时间%@",
                                 [formatter stringFromDate:[NSDate date]]];
                    [loadingCell normal];
                    loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
                    formatter=nil;

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

                
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }];
            
        }else{
            //[loadingCell normal];
            //设置分隔线正常
            self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
            lastUpdated=[NSString stringWithFormat:@"更新时间%@",
                         [formatter stringFromDate:[NSDate date]]];
            [loadingCell normal];
            loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
            formatter=nil;
        }

        
    }else if ([Config Instance].isLogin==NO){
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"未登录" message:@"登录后才能查看你的信箱" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void)fetchMailBoxInfoFromServer
{
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/mail/mailbox";
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"operation.responseObject---------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"login_resultDict------------------>%@",resultDict);
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            NSDictionary *data=[resultDict objectForKey:@"data"];
            totalMail=[[data objectForKey:@"total"]integerValue];
            
            //NSLog(@"totalMail------------------>%ld",(long)totalMail);
            
            [loadingCell loading];
            NSInteger startNum=0;
            if (totalMail>20) {
                startNum=totalMail-20+1;
            }
            
            [self fetchDataFromServerWithStartNum:startNum];
            
        }
        
        //释放掉用过的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        
    } failure:nil];
    
}

-(void)fetchMailBoxInfoFromServerNotTheFirstTime
{
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/mail/mailbox";
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"operation.responseObject---------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"login_resultDict------------------>%@",resultDict);
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            NSDictionary *data=[resultDict objectForKey:@"data"];
            totalMail=[[data objectForKey:@"total"]integerValue];
            
            //NSLog(@"totalMail------------------>%ld",(long)totalMail);
            
        }
        
        //释放掉用过的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        
    } failure:nil];
    
}



-(void)fetchDataFromServerWithStartNum:(NSInteger)startNum
{
    [loadingCell loading];
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/mail/list";
    
    NSNumber *startNumber=[NSNumber numberWithInteger:startNum];
    
    NSDictionary *param=@{@"start": startNumber};
    
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"operation.responseObject---------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"mailList_resultDict------------------>%@",resultDict);
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            
            mailListPage=[resultDict objectForKey:@"data"];
            
            //从最近的开始读起：
            for (NSInteger i=[mailListPage count]-1; i>=0; i--) {
                if (mailListPage[i]&&[mailListPage[i] isKindOfClass:[NSDictionary class]]) {
                    [mailList addObject:mailListPage[i]];
                }
            }
            
            [self.tableView reloadData];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
            lastUpdated=[NSString stringWithFormat:@"更新时间%@",
                         [formatter stringFromDate:[NSDate date]]];
            [loadingCell normal];
            loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
            formatter=nil;

            
        }else{
            //判断success的值，如果未返回一则打开登录页
            [loadingCell normal];
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
        //postList=[postListPage copy];//刷新post数据
    }
}

- (void)clear
{
    currPage =0;
    [mailList removeAllObjects];
    totalMail=0;
    [loadingCell loading];
    

    
    [self fetchMailBoxInfoFromServerNotTheFirstTime];
    
    [self.tableView reloadData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //触发上拉加载更多的条件
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0){
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mailList count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<[mailList count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mailListCell" forIndexPath:indexPath];
        
        NSString *titleStr=@"loading..";
        NSString *ownerStr=@"loading..";
        NSString *filetimeStr=@"loading..";
        
        if (mailList&&[mailList count]) {
            titleStr=[NSString stringWithFormat:@"%@",[mailList[indexPath.row]objectForKey:@"title"]];

            ownerStr=[NSString stringWithFormat:@"发自%@",[mailList[indexPath.row]objectForKey:@"owner"]];

            filetimeStr=[NSString stringWithFormat:@"%@",[mailList[indexPath.row]objectForKey:@"filetime"]];
        }
        
        ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
        
        ((UILabel *)[cell.contentView viewWithTag:2]).text=ownerStr;
        
        ((UILabel *)[cell.contentView viewWithTag:3]).text=filetimeStr;
        
        titleStr=nil;
        ownerStr=nil;
        filetimeStr=nil;

        
        return cell;

    }else{
        return loadingCell.cell;
    }
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMailDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MailDetailViewController *mailDetailViewController= segue.destinationViewController;
        
        if (mailList&&[mailList count]) {
            mailDetailViewController.mailIndex=[[mailList[indexPath.row]objectForKey:@"index"]integerValue];
            
            mailDetailViewController.navigationItem.title=[NSString stringWithFormat:@"%@",[mailList[indexPath.row]objectForKey:@"title"]];
        }else{
            //mailDetailViewController.mailIndex=0;
            mailDetailViewController.navigationItem.title=@"出错了,请退回重新加载";
        }
        
        
        mailDetailViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
    }

}

@end
