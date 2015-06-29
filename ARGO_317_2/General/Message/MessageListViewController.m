//
//  MessageListViewController.m
//  xARGO
//
//  Created by 490021684@qq.com on 14-10-12.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "MessageListViewController.h"
#import "PostListViewController.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController
@synthesize postListPage,postList,loadingCell,_tableView;
@synthesize refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知取消“新消息通知”
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noNewMessageAlert" object:nil];
    
    //初始化参数：
    currPageStartNum=0;//初始化一个较大参数
    countWhenStartNumIsOne=0;
    postListPage=[[NSMutableArray alloc]initWithCapacity:20];
    postList=[[NSMutableArray alloc]init];
    
    
    //初始化loadingCell等实例变量：
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"上拉加载更多" andLoadingStr:@"数据加载中.." andStartViewStr:@"可下拉刷新"];
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                 [dateFormatter stringFromDate:[NSDate date]]];
    isDataReady=YES;
    
    //设置分隔线样式
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;

    
    //请求服务器数据：
    postList=[[NSMutableArray alloc]init];
    [loadingCell performSelector:@selector(startView) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];;
    
    //初始化loadingHud
    loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loadingHud];
    loadingHud.delegate=self;
    loadingHud.labelText=@"loading..";
    
    //下拉刷新列表
    [self pullDownToRefresh];
    
    
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

//下拉刷新
- (void)pullDownToRefresh
{
    //UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
    refreshControl=[[UIRefreshControl alloc]init];
    refreshControl.tintColor=[UIColor lightGrayColor];
    
    refreshControl.attributedTitle=[[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    //self.refreshControl = refresh;
    [self._tableView addSubview:refreshControl];
    
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
    currPageStartNum=0;
    countWhenStartNumIsOne=0;
    if (postList) {
        [postList removeAllObjects];
    }
    isDataReady=YES;
    

    [loadingCell loading];
    
    [_tableView reloadData];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //触发上拉加载更多的条件
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0){
        [self loadData];
    }
    
}


-(void)loadData
{
    if(countWhenStartNumIsOne>=2){
        [loadingCell loading];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
        lastUpdated=[NSString stringWithFormat:@"更新时间%@",
                     [formatter stringFromDate:[NSDate date]]];
        [loadingCell normal];
        loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
        formatter=nil;
    }else{
        //第一次加载，startNum定位0
        [loadingCell loading];
        if (isDataReady) {
            isDataReady=NO;
            //NSLog(@"startNum:----------->%ld",startNum);
            [self fetchServerDataFromStartNum:currPageStartNum];
            //添加适当的时延，增强用户感知。
            //[self performSelector:@selector(hideForWhat) withObject:nil afterDelay:0];
        }
    }
}


-(void)fetchServerDataFromStartNum:(NSInteger)startNumber{
    
    NSString *urlString=[NSString stringWithFormat:@"http://argo.sysu.edu.cn/ajax/message/list?start=%ld",(long)startNumber];
    NSURL *url=[NSURL URLWithString:urlString];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //NSLog(urlString);
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"resultDict------------------>%@",resultDict);
        
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            NSDictionary *messageData=[resultDict objectForKey:@"data"];
            
            currPageStartNum=[[messageData objectForKey:@"prev"]integerValue];
            
            //使用countWhen
            if (currPageStartNum<=10&&currPageStartNum>=1) {
                countWhenStartNumIsOne++;
            }
            
            
            //NSLog(@"currPageStartNum------------------>%ld",currPageStartNum);
            
            postListPage=[messageData objectForKey:@"mlist"];
            //NSLog(@"postListPage------------------>%@",postListPage);

            
            //释放掉用过的变量：
            messageData=nil;
            requestTmp=nil;
            resData=nil;
            resultDict=nil;

            //取出单个message信息放入postList:
            for (NSDictionary *messageDict in postListPage) {
                if (![[messageDict objectForKey:@"type"]isEqualToString:@"b"]) {
                    
                    [postList addObject:messageDict];
                    
                }
                
            }
            
            //[postListPage removeAllObjects];
            
            isDataReady=YES;
            [self._tableView reloadData];
            //[loadingCell normal];
            
            if (countWhenStartNumIsOne>=2) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
                lastUpdated=[NSString stringWithFormat:@"更新时间%@",
                             [formatter stringFromDate:[NSDate date]]];
                [loadingCell normal];
                loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
                formatter=nil;
            }else{
                [loadingCell normal];
                loadingCell.label.text=@"上拉加载更多";
            }
            //NSLog(@"postList------------------>%@",postList);
            
        }else{
            isDataReady=YES;
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"error" message:@"请重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        
        //设置分隔线正常
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        isDataReady=YES;
        
        //设置分隔线正常
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
    }];
    [operation start];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (postList&&[postList count]) {
        
        return [postList count]+1;
        
    }else{
        return 1;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageListCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageListCell"];
    }
    
    if (indexPath.row <[postList count]) {
        
        //NSString *titleStr=@"loading..";
        NSString *boardName=@"loading";
        NSString *ownerStr=@"loading..";
        NSString *updateTimeStr=@"loading..";
        NSString *typeStr=@"loading";
        NSString *isReaded;
        
        
        if (postList&&[postList count]) {
            //titleStr=[NSString stringWithFormat:@"%@（%ld）",[postList[indexPath.row]objectForKey:@"title"],(long)[[postList[indexPath.row]objectForKey:@"total_reply"]integerValue]+1];
            boardName=[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"board"]];
            
            ownerStr=[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"userid"]];
            
            updateTimeStr=[self timeDescipFrom:[[postList[indexPath.row]objectForKey:@"when"]doubleValue]];
            
            typeStr=[self typeFrom:[postList[indexPath.row]objectForKey:@"type"]];
            
            isReaded=[self isReadedStringFrom:[[postList[indexPath.row]objectForKey:@"unread"]doubleValue]];
            
        }
        /*
        if ([boardName isEqualToString:@""]) {
            boardName=@"某个";
        }
        
        if ([ownerStr isEqualToString:@""]) {
            ownerStr=@"有人";
        }
         */
        
        if ([[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"type"]]isEqualToString:@"b"]) {
            ((UILabel *)[cell.contentView viewWithTag:1]).text=@"生日提醒";
        }else{
            ((UILabel *)[cell.contentView viewWithTag:1]).text=[NSString stringWithFormat:@"%@在%@版块%@",ownerStr,boardName,typeStr];
        }
        
        ((UILabel *)[cell.contentView viewWithTag:2]).text=updateTimeStr;
        
        ((UILabel *)[cell.contentView viewWithTag:3]).text=[NSString stringWithFormat:@"%@",isReaded];
        
        
        //titleStr=nil;
        boardName=nil;
        ownerStr=nil;
        updateTimeStr=nil;
        typeStr=nil;
        isReaded=nil;
        
        
        return cell;
        
    }else{
        //最后一项，加载更多
        return loadingCell.cell;
    }
}

- (NSString *)typeFrom:(NSString *)type{
    if ([type isEqualToString:@"@"]) {
        return @"@我了";
    }else if([type isEqualToString:@"r"]){
        return @"回复我了";
    }else{
        return @"回复我了";
    }
}

- (NSString *)isReadedStringFrom:(NSInteger)unread{
    if (unread==1) {
        return @"未读";
    }else{
        return @"已读";
    }
}

/*

//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<[postList count]) {
        return [self getTheHeight:indexPath.row];
        
    }else{
        return 50;
    }
}



//计算行高
-(CGFloat) getTheHeight:(NSInteger)row
{
    // 显示的内容
    NSString *titleStr=[NSString stringWithFormat:@"%@（%ld）",[postList[row]objectForKey:@"title"],(long)[[postList[row]objectForKey:@"total_reply"]integerValue]+1];
    
    // 计算出高度
    NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    
    CGSize size=[titleStr boundingRectWithSize:CGSizeMake(295,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    
    
    CGFloat height=size.height;
    
    
    //释放内存：
    titleStr=nil;
    
    attribute=nil;
    
    // 返回需要的高度,这里的判断不需要那么严格
    return height+30;
    
}


*/





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostViewFromMessageListView"]) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        NSIndexPath *indexPath = [self._tableView indexPathForSelectedRow];
        if ([[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"type"]]isEqualToString:@"b"]) {
            
        }else{
            PostListViewController *postViewController= segue.destinationViewController;
            postViewController.boardName=[postList[indexPath.row]objectForKey:@"board"];
            if (postList&&[postList count]) {
                postViewController.fileName = [self.postList[indexPath.row]objectForKey:@"filename"];
                postViewController.navigationItem.title=@"提醒详情";
                
                //标记提醒已读：
                int postIndex=[[postList[indexPath.row]objectForKey:@"index"]intValue];
                NSNumber *postIndexNumber=[NSNumber numberWithInt:postIndex];
                NSString *urlString=[NSString stringWithFormat:@"http://argo.sysu.edu.cn/ajax/message/mark"];
                NSDictionary *param=@{@"index":postIndexNumber};
                [[AFHTTPRequestOperationManager manager] POST:urlString parameters:param success:nil failure:nil];
            }else{
                postViewController.fileName=@"";
                postViewController.navigationItem.title=@"请退回重新进入";
            }
            postViewController=nil;//important!否则如果持续使用会导致内存被塞满
            indexPath=nil;
        }
    }
}
@end
