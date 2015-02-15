//
//  HomeViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-18.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "HomeViewController.h"
#import "PostListViewController.h"
#import "AFNetworking.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface HomeViewController () {
    BOOL isTopTenDataReady;
    BOOL isFreshDataReady;
}

@end

@implementation HomeViewController
@synthesize topTenTopics,freshTopics;


//load the data
-(void)loadData
{
    //展示页面加载效果
    //[loadingCell startView];
    
    [self performSelector:@selector(fetchTopTensDataFromServer) withObject:nil afterDelay:0];
    [self performSelector:@selector(fetchFreshTopicFromeServer) withObject:nil afterDelay:0];
    
}


//获取十大数据
-(void)fetchTopTensDataFromServer
{
    NSURL *url=[NSURL URLWithString:@"http://argo.sysu.edu.cn/ajax/comm/topten"];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"sucesss:%@",operation.responseObject);
        
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"topten_resultDict-------------->%@",resultDict);
        NSMutableArray *data=[resultDict objectForKey:@"data"];
        for (NSDictionary *item in data) {
            if (item&&[item isKindOfClass:[NSDictionary class]]) {
                [self.topTenTopics addObject:item];

            }
        }
        //记录更新时间：
        lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                     [dateFormatter stringFromDate:[NSDate date]]];
        
        //NSLog(@"topten_toptenTopics-------------->%@",topTenTopics);
        //释放掉用过的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        data=nil;
        isTopTenDataReady = YES;
        [self.tableView reloadData];
        [loadingCell normal];
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        //NSLog(@"Failure: %@", operation.error);
        
        //UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[av show];
    }];
    [operation start];
    
}

-(void)fetchFreshTopicFromeServer
{
    //展示页面加载效果
    [loadingCell performSelector:@selector(loading) withObject:nil afterDelay:0];
    currPage++;
    NSInteger cursor=(currPage-1)*32;//一次可获取32条
    NSLog(@"cursor-------------->%ld",(long)cursor);
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/v2/top/topic";
    NSNumber *cursorNumber=[NSNumber numberWithInteger:cursor];
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"cursor":cursorNumber}];
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        //NSLog(@"success------------------------>%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"FreshTopic_resultDict------------------>%@",resultDict);
        
        NSDictionary *items=[resultDict objectForKey:@"items"];
        //NSLog(@"items------------------>%@",items);
        if (items&&[items isKindOfClass:[NSDictionary class]]) {
            freshTopicsPerCursor=[items allValues];
            for (NSObject *object in freshTopicsPerCursor) {
                if (object&&[object isKindOfClass:[NSDictionary class]]) {
                    
                    [self.freshTopics addObject:object];
                }
            }
        }
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        //释放掉用过的变量
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        items=nil;
        
        isFreshDataReady = YES;
        //NSLog(@"freshTopics-------------->%@",freshTopics);
        
        [self.tableView reloadData];
        [loadingCell normal];
        
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        //设置分隔线正常
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        //NSLog(@"Failure: %@", operation.error);
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    //如果有有效cookie，则自动登录
    NSHTTPCookieStorage *myCookie=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies] ) {
        NSLog(@"cookie--------->%@",cookie);
        NSLog(@"value-------->%@",[cookie valueForKey:@"value"]);
        
        //cookie的值需要和
        if ([cookie valueForKey:@"value"]&&[[cookie valueForKey:@"value"] integerValue]==666666) {
            //将登录状态存入cookie
            [Config Instance].isLogin=YES;
            [[Config Instance]saveCookie:[Config Instance].isLogin];
            
        }
    }
     */
    
    //初始化实例变量
    freshTopics=[[NSMutableArray alloc]init];
    freshTopicsPerCursor=[[NSArray alloc]init];
    topTenTopics=[[NSMutableArray alloc]initWithCapacity:10];
    currPage=0;
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"上拉加载更多" andLoadingStr:@"数据加载中.." andStartViewStr:@"可下拉刷新"];
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                 [dateFormatter stringFromDate:[NSDate date]]];
    
    
    //设置分隔线样式
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;

    
    //加载数据
    [loadingCell startView];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
    
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
    currPage = 0;

    [topTenTopics removeAllObjects];
    [freshTopics removeAllObjects];
    
    isTopTenDataReady=NO;
    isFreshDataReady=NO;
    [loadingCell loading];
    
    [self.tableView reloadData];
}

//上拉加载更多
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //触发上拉加载更多的条件
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0){
        [self performSelector:@selector(fetchFreshTopicFromeServer) withObject:nil afterDelay:0.2];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *HeaderString = nil;
    switch (section) {
        case 0:
            HeaderString=@"今日十大";
            break;
        case 1:
            HeaderString=@"新鲜发言";
            break;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 320, 15)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    UILabel *HeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 15)];
    HeaderLabel.backgroundColor = [UIColor clearColor];
    HeaderLabel.font = [UIFont boldSystemFontOfSize:14];
    HeaderLabel.textColor = [UIColor blackColor];
    HeaderLabel.text = HeaderString;
    [headerView addSubview:HeaderLabel];
    
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNumber = 0;
    switch (section) {
        case 0:
            if (topTenTopics&&[topTenTopics count]) {
                rowNumber = [topTenTopics count];
            }else{
                rowNumber=0;
            }
            break;
        case 1:
            if (freshTopics&&[freshTopics count]) {
                rowNumber = [freshTopics count] + 1;
            }else{
                rowNumber=1;
            }
            break;
    }
    return rowNumber;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (isTopTenDataReady && isFreshDataReady) {
        return 22;
    }
    return 0;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topTenCell"];
    
    if (section == 1 && indexPath.row == freshTopics.count) {
        return loadingCell.cell;
    } else {
        NSString *titleStr=@"loading..";
        NSString *boardNameStr=@"loading..";
        NSString *authorStr=@"loading..";
        NSString *timeStr=@"loading..";
        
        if (section == 0) {
            
            if (topTenTopics&&[topTenTopics count]) {
                
                titleStr=[NSString stringWithFormat:@"%@",[topTenTopics[indexPath.row]objectForKey:@"title"]];
                
                boardNameStr=[NSString stringWithFormat:@"%@",[topTenTopics[indexPath.row]objectForKey:@"board"]];
                
                authorStr=[NSString stringWithFormat:@"%@",[topTenTopics[indexPath.row]objectForKey:@"author"]];
                
                timeStr=[self timeDescipFrom:[[topTenTopics[indexPath.row]objectForKey:@"time"]doubleValue]];
            }
            
        } else {
            
            if (freshTopics&&[freshTopics count]) {
                titleStr=[NSString stringWithFormat:@"%@（%ld）",[freshTopics[indexPath.row]objectForKey:@"title"],(long)[[freshTopics[indexPath.row]objectForKey:@"replynum"]integerValue]+1];
                
                boardNameStr=[NSString stringWithFormat:@"%@",[freshTopics[indexPath.row]objectForKey:@"boardname"]];
                
                authorStr=[NSString stringWithFormat:@"%@",[freshTopics[indexPath.row]objectForKey:@"author"]];
                
                timeStr=[self timeDescipFrom:[[freshTopics[indexPath.row]objectForKey:@"posttime"]doubleValue]];

            }
        }
        
        ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
        
        ((UILabel *)[cell.contentView viewWithTag:2]).text=boardNameStr;
        
        ((UILabel *)[cell.contentView viewWithTag:3]).text=authorStr;
        
        ((UILabel *)[cell.contentView viewWithTag:4]).text=timeStr;
        
        //释放掉用过的变量：
        titleStr=nil;
        boardNameStr=nil;
        authorStr=nil;
        timeStr=nil;
        
        return cell;
    }
    
}


//将时间戳转为时间,然后再转为可理解的字符串
-(NSString *)timeDescipFrom:(double)timeStr
{
    
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    
    NSDate *theday = [NSDate dateWithTimeIntervalSince1970:timeStr];
    //NSLog(@"theday------------------>%@",theday);
    NSString *str=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:theday]];
    
    theday=nil;
    
    return str;
}

//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (section == 1 && indexPath.row == freshTopics.count) {
        return 50;
    } else {
        
        if (section == 0) {
            // 显示的内容
            NSString *titleStr=[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[topTenTopics[indexPath.row]objectForKey:@"title"]]];
            
            // 计算出高度
            NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
            
            CGSize size=[titleStr boundingRectWithSize:CGSizeMake(300,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            
            
            CGFloat height=size.height;
            
            
            //释放内存：
            titleStr=nil;
            
            attribute=nil;
            
            // 返回需要的高度
            return height+30;
            
        } else {
            NSString *titleStr=[NSString stringWithFormat:@"%@（%ld）",[freshTopics[indexPath.row]objectForKey:@"title"],(long)[[freshTopics[indexPath.row]objectForKey:@"replynum"]integerValue]+1];
            
            // 计算出高度
            NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
            
            CGSize size=[titleStr boundingRectWithSize:CGSizeMake(300,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            
            
            CGFloat height=size.height;
            
            
            //释放内存：
            titleStr=nil;
            
            attribute=nil;
            
            // 返回需要的高度
            return height+30;

            
        }
    }
}


#pragma mark - Navigation


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     
     if ([segue.identifier isEqualToString:@"showPostFromHomeView"]) {
         
         NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         
         NSInteger section = indexPath.section;
         
         PostListViewController *destViewController = segue.destinationViewController;
         
         if (section==0) {
             
             if (topTenTopics&&[topTenTopics count]) {
                 destViewController.boardName=[[topTenTopics objectAtIndex:indexPath.row]objectForKey:@"board"];
                 
                 destViewController.fileName=[[topTenTopics objectAtIndex:indexPath.row]objectForKey:@"filename"];
                 
                 NSString *titleStr=[NSString stringWithFormat:@"%@",[[topTenTopics objectAtIndex:indexPath.row]objectForKey:@"title"]];
                 
                 destViewController.navigationItem.title=titleStr;
             }else{
                 destViewController.boardName=@"";
                 destViewController.fileName=@"";
                 destViewController.navigationItem.title=@"请退回重新进入";
             }
         }else{
             if (freshTopics&&[freshTopics count]) {
                 destViewController.boardName=[freshTopics[indexPath.row]objectForKey:@"boardname"];
                 
                 destViewController.fileName=[NSString stringWithFormat:@"M.%@.A",[freshTopics[indexPath.row]objectForKey:@"posttime"]];
                 
                 destViewController.navigationItem.title=[NSString stringWithFormat:@"%@",[freshTopics[indexPath.row]objectForKey:@"title"]];
             }else{
                 destViewController.boardName=@"";
                 destViewController.fileName=@"";
                 destViewController.navigationItem.title=@"请退回重新进入";
             }
         }
         destViewController=nil;//当返回时，释放内存！否则如果持续使用会导致内存被塞满
         
         indexPath=nil;
 
     }
}





@end
