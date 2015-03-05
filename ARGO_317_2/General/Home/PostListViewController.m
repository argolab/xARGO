//
//  PostViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-26.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//
// This contains a 3-stages lazy load:
// 1. No data.
// 2. List ready.
// 3. Rendering cell when visible.

#import "PostListViewController.h"
#import "AddPostViewController.h"
#import "UserQueryViewController.h"
#import "AttachPictureViewController.h"
#import "DataManager.h"

//定义cell里面的tag
#define authorTag       1
#define post_timeTag    2
#define rawcontentTag   3
#define floorTag        4
#define hasPictureTag   5

static long batchCount = 3;

static NSString *CellIdentifier = @"postCell";

@implementation PostListViewController
@synthesize boardName,fileName;
@synthesize postTopicList,postList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void) initTopicList {
    postTopicList = [[NSMutableArray alloc]init];
    [loadingCell loading];
    [[DataManager manager] getPostsPerTopicByBoardName:boardName andFile:fileName success:^(NSDictionary *resultDict){
        NSLog(@"On getting topic successfully.");
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            NSArray *data=[resultDict objectForKey:@"data"];
            postList = [NSMutableArray arrayWithCapacity:[data count]];
            for (int i=0; i<[data count]; i++) {
                if ([data objectAtIndex:i]) {
                    // init postList before postTopicList to avoid NilException. Should be done in a better way?
                    [postList addObject:[NSNull null]];
                    [postTopicList addObject:[data objectAtIndex:i]];
                }
            }
            
            //记录数据加载时间
            lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@", [dateFormatter stringFromDate:[NSDate date]]];
            [self fetchInBatch:0 count: batchCount];
            }
        } failure:^(NSString *data, NSError *error) {
        // failed?
        }
     ];

}

// -------------------------------------------------------------------------------
//  viewDidLoad
// -------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    dateFormatter.dateFormat=@"yyyy/MM/dd, HH:mm";
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"上拉刷新" andLoadingStr:@"数据加载中.." andStartViewStr:@"可下拉刷新.."];
    [loadingCell loading];

    // Load list asynchously.
    [self initTopicList];

}

// -------------------------------------------------------------------------------
//  didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

// -------------------------------------------------------------------------------
//  tableView:numberOfRowsInSection:
//  Customize the number of rows in the table view.
// -------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if there's no data yet, return 1 for the loading cell.
    return self.postTopicList.count == 0? 1:self.postTopicList.count;
}

// -------------------------------------------------------------------------------
//  tableView:cellForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSUInteger nodeCount = self.postTopicList.count;
    
    if (nodeCount == 0 && indexPath.row == 0)    {
        return loadingCell.cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Set up the cell representing the app
    NSDictionary *post = (self.postList)[indexPath.row];
    [self composite:cell at:indexPath with:post];
    
    if(post == (id)[NSNull null]) {
        NSLog(@"Going to fetch:%@",[postTopicList objectAtIndex:indexPath.row]);
        
        [[DataManager manager] getPostByBoard:boardName andFile:[postTopicList objectAtIndex:indexPath.row] success:^(NSDictionary *resultDict) {
            NSLog(@"On fetching successfully:%@",[[resultDict objectForKey:@"data"] objectForKey:@"filename"]);
            if ([resultDict objectForKey:@"data"]&&[[resultDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]]) {
                self.postList[indexPath.row]=[resultDict objectForKey:@"data"];
                [self composite:cell at:indexPath with:self.postList[indexPath.row]];
            }
            NSLog(@"TableView rows=%ld",(long)[tableView numberOfRowsInSection:0]);
            NSLog(@"Going to reload row=%@",indexPath);
            NSLog(@"The cell=%@",[tableView cellForRowAtIndexPath:indexPath]);
            if([tableView cellForRowAtIndexPath:indexPath]) {                                                                            [tableView beginUpdates];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }
            

        } failure:^(NSString *data, NSError *error) {
            NSLog(@"When fetching failed.");
        }];
    }
//    Dispatch this in non-main queue to avoid infinite loop:
//    if ((indexPath.row + batchCount < postTopicList.count) && postList[indexPath.row + batchCount] == [NSNull null]) {
//        [self fetchInBatch:indexPath.row + 2 count:batchCount];
//    }
    
    NSLog(@"Returning cell=%@",cell);
    return cell;
}

-(void) fetchInBatch:(long) from count:(long) count {
    assert(postTopicList.count > 0);
    assert(count >= 0);
    __block int counter = 0;
    unsigned long threshold = MIN(count, postTopicList.count - from);
    NSLog(@"Going to fetch next %ld from %ld", count, from);
    for (int i = 0; i < threshold; ++i) {
        NSLog(@"Going to fetch :%@", [postTopicList objectAtIndex:i]);
        [[DataManager manager] getPostByBoard:boardName andFile:[postTopicList objectAtIndex:i] success:^(NSDictionary *resultDict) {
            NSLog(@"On fetching successfully:%@",[[resultDict objectForKey:@"data"] objectForKey:@"filename"]);
            if ([resultDict objectForKey:@"data"]&&[[resultDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]]) {
                self.postList[i]=[resultDict objectForKey:@"data"];
            }
            ++counter;
            if(counter == threshold) {
                [self.tableView reloadData];
            }
        } failure:^(NSString *data, NSError *error) {
            NSLog(@"When fetching failed, data=%@, error=%@", data, error);
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"请退回重新进入或者重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }];
    }
}

- (void) composite:(UITableViewCell *) cell at:(NSIndexPath *) indexPath
                  with:(NSDictionary *) data {
    NSLog(@"Compositing cell %@ at %@ with %@", cell, indexPath, data);
    NSString *authorStr=@"loading...";
    NSString *post_timeStr=@"loading...";
    NSString *floorStr=[NSString stringWithFormat:@"#%ld",(long)indexPath.row+1];
    NSString *rawcontentStr=@"loading...";
    NSInteger hasPicture=0;
    
    //赋值：
    if (data != (id)[NSNull null]) {
        authorStr=[NSString stringWithFormat:@"%@(%@)",[data objectForKey:@"userid"],[data objectForKey:@"username"]];
        post_timeStr=[self formatTime:[[data objectForKey:@"post_time"]doubleValue]];
        floorStr=[NSString stringWithFormat:@"#%ld",(long)indexPath.row+1];
        rawcontentStr=[NSString stringWithFormat:@"%@",[data objectForKey:@"rawcontent"]];
        
        //如果有附图，则赋值给isPicture;
        if ([data objectForKey:@"ah"]&&[[data objectForKey:@"ah"]count]) {
            if ([[data objectForKey:@"ah"]isKindOfClass:[NSDictionary class]]) {
                NSDictionary *ah=[data objectForKey:@"ah"];
                hasPicture=[[ah objectForKey:@"is_picture"]integerValue];
                ah=nil;
            }
        }
    }
    
    ((UILabel *)[cell.contentView viewWithTag:authorTag]).text=authorStr;
    ((UILabel *)[cell.contentView viewWithTag:post_timeTag]).text=post_timeStr;
    ((UITextView *)[cell.contentView viewWithTag:rawcontentTag]).text=rawcontentStr;
    ((UILabel *)[cell.contentView viewWithTag:floorTag]).text=floorStr;
    ((UIButton *)[cell.contentView viewWithTag:hasPictureTag]).hidden=!hasPicture;
}

//将时间戳转为时间,然后再转为可理解的字符串
-(NSString *) formatTime:(double)timeStr {
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStr]];
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    //初始化实例变量：
//    currPage=0;
//    isAllDataFinished=NO;
//    isDataReady=NO;
//    postTopicList=[[NSMutableArray alloc]init];
//    postFeeds=[[NSMutableArray alloc]init];
//    tempPostFeeds=[[NSMutableArray alloc]init];
//    //postFeed=[[NSDictionary alloc]init];
//    //NSString *nomalStr=[NSString stringWithFormat:@"更新于%@",lastUpdated];
//    dateFormatter=[[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
//    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
//                 [dateFormatter stringFromDate:[NSDate date]]];
//    
//    //设置分隔线样式
//    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;
//    
//    //启动loadingCell
//    [loadingCell performSelector:@selector(startView) withObject:nil afterDelay:0];
//    
//    //加载数据：
//    if ([self.navigationItem.title isEqualToString:@"提醒详情"]) {
//        [self fetchMessageDetail];
//    }else{
//        [self loadData];
//        //下拉刷新列表
//        [self pullDownToRefresh];
//    }
//}
//
//-(void)fetchMessageDetail{
//    [loadingCell loading];
//    
//    [[DataManager manager] getPostByBoard:boardName andFile: fileName
//        success:^(NSDictionary *resultDict) {
//        //NSLog(@"resultDict------------------>%@",resultDict);
//        //postFeeds=[resultDict objectForKey:@"data"];
//        if ([resultDict objectForKey:@"data"]) {
//            [postFeeds addObject:[resultDict objectForKey:@"data"]];
//        }
//        
//        [self.tableView reloadData];
//        
//        //数据准备好了
//        isDataReady=YES;
//        
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
//        lastUpdated=[NSString stringWithFormat:@"更新时间:%@",
//                     [formatter stringFromDate:[NSDate date]]];
//        [loadingCell normal];
//        loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
//        formatter=nil;
//        //设置分隔线正常
//        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//        //NSLog(@"tempPostFeeds-------------->%@",tempPostFeeds);
//    }failure: ^(NSString *data, NSError *error){
//        
//        //设置分隔线正常
//        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//        
//        
//        //NSLog(@"Failure: %@", operation.error);
//        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        
//    }];
//
//
//    
//}
//
//
////下拉刷新
//- (void)pullDownToRefresh
//{
//    UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
//    refresh.tintColor=[UIColor lightGrayColor];
//    refresh.attributedTitle=[[NSAttributedString alloc]initWithString:@"下拉刷新"];
//    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
//    self.refreshControl = refresh;
//    
//}
//
////下拉刷新调用的方法
//-(void)handleData
//{
//    [self loadData];
//    //[self fetchPostWithBoardName:boardName andFilename:fileName];
//    [self.refreshControl endRefreshing];
//}
//
////下拉刷新调用的方法
//-(void)refreshView:(UIRefreshControl *)refresh
//{
//    if (refresh.refreshing) {
//        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
//        //页数重新定位在最前面,清空数组
//        [self clear];
//        [self performSelector:@selector(handleData) withObject:nil afterDelay:1.2];
//        //postList=[postListPage copy];//刷新post数据
//    }
//}
//
//- (void)clear
//{
//    [postTopicList removeAllObjects];
//    [postFeeds removeAllObjects];
//    [tempPostFeeds removeAllObjects];
//    currPage=0;
//    isAllDataFinished=NO;
//    isDataReady=NO;
//    
//    [loadingCell loading];
//    
//    [self.tableView reloadData];
//}
//
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//// 加载同主题所有filename数组数据
//-(void)loadData
//{
//    [loadingCell loading];
//    
//    [self fetchPostWithBoardName:boardName andFilename:fileName];
//
//}
//
////从服务器获取数据：先获取postTopicList,再通过postTopicList获取帖子详细内容
//-(void)fetchPostWithBoardName:(NSString *)boardname andFilename:(NSString *)filename
//{
//    //页数加一
//    currPage++;
//    
//    [[DataManager manager] getPostsPerTopicByBoardName:boardname andFile:filename
//        success:^(NSDictionary *resultDict){
//        int success=[[resultDict objectForKey:@"success"]intValue];
//        if (success==1) {
//            NSArray *data=[resultDict objectForKey:@"data"];
//            
//            for (int i=0;i<[data count];i++) {
//                if ([data objectAtIndex:i]) {
//                    [postTopicList addObject:[data objectAtIndex:i]];
//                }
//            }
//            //NSLog(@"postTopicList------------------>%@%lu",postTopicList,(unsigned long)[postTopicList count]);
//            
//            //记录数据加载时间
//            lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
//                         [dateFormatter stringFromDate:[NSDate date]]];
//            
//            //如果数目小于等于20（一页的数据），则一次请求完所有数据,否则，一次只加载前面20个postFeed先：
//            if ([postTopicList count]<=20) {
//                isAllDataFinished=YES;
//                for (int i=0; i<[postTopicList count]; i++)
//                {
//                    [self fetchPostFeedWithBoardName:boardName andFileName:[postTopicList objectAtIndex:i]];
//                }
//            } else {
//                isAllDataFinished=NO;
//                for (int i=0; i<20; i++)
//                {
//                    [self fetchPostFeedWithBoardName:boardName andFileName:[postTopicList objectAtIndex:i]];
//                }
//            }
//        } else {
//            
//            //设置分隔线正常
//            self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//
//            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"请退回重新进入或者重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [av show];
//            
//        }
//        
//    }failure:^(NSString *data, NSError *error){
//        
//        //设置分隔线正常
//        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//
//        //NSLog(@"Failure: %@", operation.error);
//        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//        
//    }];
//
//}
//
//-(void)fetchPostFeedWithBoardName:(NSString *)boardname andFileName:(NSString *)filename
//{
//    [loadingCell loading];
//    NSLog(@"FetchingPostFeed.");
//    [[DataManager manager] getPostByBoard:boardname andFile:filename
//                success:^(NSDictionary *resultDict) {
//                    NSLog(@"WhenFetchingSucces.");
//
//        if ([resultDict objectForKey:@"data"]&&[[resultDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]]) {
//            [tempPostFeeds addObject:[resultDict objectForKey:@"data"]];
//        }
//        //NSLog(@"tempPostFeeds-------------->%@",tempPostFeeds);
//           
//        //由于采用异步网络请求，所以加载完毕后postFeeds里面的对象顺序很可能被打乱了，当postFeeds加载完毕时，对其中的元素按发帖时间排序。
//        //分所有帖子加载完了和没有加载完两种情况：
//        if (isAllDataFinished) {
//            
//            if ([tempPostFeeds count]==[postTopicList count]-20*(currPage-1)) {
//                
//                NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc]initWithKey:@"filename" ascending:YES];
//                
//                NSArray *tempArray=[tempPostFeeds sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//                
//                //NSLog(@"tempPostFeeds-------------->%@",tempPostFeeds);
//                [tempPostFeeds removeAllObjects];
//                
//                for (NSDictionary *feed in tempArray) {
//                    if (feed&&[feed isKindOfClass:[NSDictionary class]]) {
//                        [postFeeds addObject:feed];
//                    }
//                }
//                
//                sortDescriptor=nil;
//                tempArray=nil;
//                
//                
//                [self.tableView reloadData];
//                
//                //数据准备好了
//                isDataReady=YES;
//                
//                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
//                lastUpdated=[NSString stringWithFormat:@"更新时间:%@",
//                             [formatter stringFromDate:[NSDate date]]];
//                [loadingCell normal];
//                loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
//                formatter=nil;
//                //设置分隔线正常
//                self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//            }
//
//        }else{
//            if ([tempPostFeeds count]==20) {
//                
//                NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc]initWithKey:@"filename" ascending:YES];
//                
//                NSArray *tempArray=[tempPostFeeds sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//                
//                //NSLog(@"tempPostFeeds-------------->%@",tempPostFeeds);
//                [tempPostFeeds removeAllObjects];
//                
//                for (NSDictionary *feed in tempArray) {
//                    if (feed&&[feed isKindOfClass:[NSDictionary class]]) {
//                        [postFeeds addObject:feed];
//                    }
//                }
//                
//                sortDescriptor=nil;
//                tempArray=nil;
//                
//                
//                [self.tableView reloadData];
//                
//                //数据准备好了
//                isDataReady=YES;
//                
//                [loadingCell normal];
//                loadingCell.label.text=@"上拉还有更多";
//                //设置分隔线正常
//                self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//            }
//
//        }
//        
//            //NSLog(@"postFeeds--------------------->%@",postFeeds);
//        
//    }failure:nil];
//    NSLog(@"FetchedPostFeed.");
//
//}
//
//
//- (void)loadMorePostFeed{
//    
//    currPage++;//如果帖子很多，第一次上拉的时候，currPage现在是2:
//    NSLog(@"currPage--------------------------->%ld",(long)currPage);
//    if ([postTopicList count]>currPage*20) {
//        //NSLog(@"postTopicList-------------------->%@",postTopicList);
//        //帖子还有很多：
//        //如果上一页的数据还没准备好，不许加载数据先：
//        if (!isDataReady) {
//            currPage--;
//        }else{
//            isAllDataFinished=NO;
//            isDataReady=NO;
//            for (NSInteger i=(currPage-1)*20; i<20*currPage; i++)
//            {
//                [self fetchPostFeedWithBoardName:boardName andFileName:[postTopicList objectAtIndex:i]];
//            }
//        }
//        
//    }else if ([postTopicList count]>(currPage-1)*20&&[postTopicList count]<=currPage*20){
//        //加载完这次，帖子暂时算是加载完了：
//        //如果上一页的数据还没准备好，不许加载数据先：
//        if (!isDataReady) {
//            currPage--;
//        }else{
//            isAllDataFinished=YES;
//            isDataReady=NO;
//            for (NSInteger i=(currPage-1)*20; i<[postTopicList count]; i++)
//            {
//                [self fetchPostFeedWithBoardName:boardName andFileName:[postTopicList objectAtIndex:i]];
//            }
//
//        }
//    }else{
//        //页数不再增加了
//        currPage--;
//        //数据准备好了才能
//        if (isDataReady) {
//            //等待上拉刷新：
//             [[DataManager manager] getPostsPerTopicByBoardName:boardName andFile:fileName
//                success:^(NSDictionary *resultDict) {
//                NSArray *data=[resultDict objectForKey:@"data"];
//                
//                if ([data count]>[postTopicList count]) {
//                    [loadingCell loading];
//                    //记录帖子差多少：
//                    NSInteger postFeedAddCount=[data count]-[postTopicList count];
//                    //更新postTopicList:
//                    for (NSInteger i=[data count]-postFeedAddCount;i<[data count];i++) {
//                        if ([data objectAtIndex:i]) {
//                            [postTopicList addObject:[data objectAtIndex:i]];
//                        }
//                    }
//                    for (NSInteger i=[data count]-postFeedAddCount; i<[data count]; i++) {
//                        NSString *curFileName=[data objectAtIndex:i];
//                        [[DataManager manager] getPostByBoard:boardName andFile: curFileName
//                                                      success:^(NSDictionary *resultDict) {
//                            if ([resultDict objectForKey:@"data"]&&[[resultDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]]) {
//                                [tempPostFeeds addObject:[resultDict objectForKey:@"data"]];
//                            }
//                            //由于采用异步网络请求，所以加载完毕后postFeeds里面的对象顺序很可能被打乱了，当postFeeds加载完毕时，对其中的元素按发帖时间排序。
//                            if ([tempPostFeeds count]==postFeedAddCount) {
//                                
//                                NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc]initWithKey:@"filename" ascending:YES];
//                                
//                                NSArray *tempArray=[tempPostFeeds sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//                                
//                                //NSLog(@"tempPostFeeds-------------->%@",tempPostFeeds);
//                                [tempPostFeeds removeAllObjects];
//                                
//                                for (NSDictionary *feed in tempArray) {
//                                    if (feed&&[feed isKindOfClass:[NSDictionary class]]) {
//                                        [postFeeds addObject:feed];
//                                    }
//                                }
//                                
//                                sortDescriptor=nil;
//                                tempArray=nil;
//                                
//                                
//                                [self.tableView reloadData];
//                                
//                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                                [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
//                                lastUpdated=[NSString stringWithFormat:@"更新时间:%@",
//                                             [formatter stringFromDate:[NSDate date]]];
//                                [loadingCell normal];
//                                loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
//                                formatter=nil;
//                                
//                                //NSLog(@"postFeeds--------------------->%@",postFeeds);
//                            }
//                            
//                        }failure:nil];
//                        
//                    }
//                    
//                }else{
//                    
//                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//                    [formatter setDateFormat:@"MMM/dd, HH:mm:ss"];
//                    lastUpdated=[NSString stringWithFormat:@"更新时间:%@",
//                                 [formatter stringFromDate:[NSDate date]]];
//                    [loadingCell normal];
//                    loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
//                    formatter=nil;
//                    
//                }
//            }failure:^(NSString *data, NSError *error){
//                //NSLog(@"Failure: %@", operation.error);
//                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [av show];
//                
//            }];
//        }
//    }
//}
//
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    //触发上拉加载更多的条件
//    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0){
//        //如果是提醒详情，则不需要上拉加载更多
//        if ([self.navigationItem.title isEqualToString:@"提醒详情"]==NO) {
//            [self performSelector:@selector(loadMorePostFeed) withObject:nil afterDelay:0];
//            
//        }
//    }
//    
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [postFeeds count]+1;
//}
//
//
//-(UITableViewCell *)tableViewCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier = @"postCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    
//    if (indexPath.row <[postFeeds count]) {
//        
//        if (cell == nil)
//        {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        
//        NSString *authorStr=@"loading...";
//        NSString *post_timeStr=@"loading...";
//        NSString *floorStr=[NSString stringWithFormat:@"#%ld",(long)indexPath.row+1];
//        NSString *rawcontentStr=@"loading...";
//        NSInteger isPicture=0;
//        
//        //赋值：
//        if (postFeeds&&[postFeeds count]) {
//            authorStr=[NSString stringWithFormat:@"%@(%@)",[postFeeds[indexPath.row]objectForKey:@"userid"],[postFeeds[indexPath.row] objectForKey:@"username"]];
//            
//            post_timeStr=[self timeDescipFrom:[[postFeeds[indexPath.row] objectForKey:@"post_time"]doubleValue]];
//            floorStr=[NSString stringWithFormat:@"#%ld",(long)indexPath.row+1];
//            
//            rawcontentStr=[NSString stringWithFormat:@"%@",[postFeeds[indexPath.row] objectForKey:@"rawcontent"]];
//            
//            //如果有附图，则赋值给isPicture;
//            if ([postFeeds[indexPath.row]objectForKey:@"ah"]&&[[postFeeds[indexPath.row]objectForKey:@"ah"]count]) {
//                if ([[postFeeds[indexPath.row]objectForKey:@"ah"]isKindOfClass:[NSDictionary class]]) {
//                    NSDictionary *ah=[postFeeds[indexPath.row]objectForKey:@"ah"];
//                    isPicture=[[ah objectForKey:@"is_picture"]integerValue];
//                    ah=nil;
//                }
//            }
//        }
//        
//        //发帖人,显示userid(username)这样的格式
//        ((UILabel *)[cell.contentView viewWithTag:authorTag]).text=authorStr;
//        
//        //发帖时间
//        ((UILabel *)[cell.contentView viewWithTag:post_timeTag]).text=post_timeStr;
//        
//        //楼层位置
//        ((UILabel *)[cell.contentView viewWithTag:4]).text=floorStr;
//        
//        //帖子内容
//        //((UICopyLabel *)[cell.contentView viewWithTag:rawcontentTag]).text=rawcontentStr;
//        //UITextView *contentTextView=((UITextView *)[cell.contentView viewWithTag:rawcontentTag]);
//        ((UITextView *)[cell.contentView viewWithTag:rawcontentTag]).text=rawcontentStr;
//        //contentTextView.text=rawcontentStr;
//        //contentTextView.frame=CGRectMake(15, 30, 300, CGFLOAT_MAX);
//        
//        
//        //附图按钮:如果有附图，则显示按钮，没有附图则隐藏按钮：
//        if (isPicture) {
//            [(UIButton *)[cell.contentView viewWithTag:5] setHidden:NO];
//        }else{
//            [(UIButton *)[cell.contentView viewWithTag:5] setHidden:YES];
//        }
//        
//        
//
//        //释放变量：
//        authorStr=nil;
//        post_timeStr=nil;
//        floorStr=nil;
//        rawcontentStr=nil;
//        
//        
//        return cell;
//
//    }else{
//        
//        return loadingCell.cell;
//    }
//}
//
//
//
//

//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<[postList count] && postList[indexPath.row]!=[NSNull null]) {
        return [self getTheHeight:indexPath.row];
    } else {
        return 100;
    }
}

//计算行高
-(CGFloat) getTheHeight:(NSInteger)row {
    // 显示的内容
    NSString *rawcontentStr=[postList[row] objectForKey:@"rawcontent"];
    
    // 计算出高度
    NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize size=[rawcontentStr boundingRectWithSize:CGSizeMake(290,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    CGFloat height=size.height;
    
    //释放内存：
    rawcontentStr=nil;
    attribute=nil;
    
    // 返回需要的高度,这里的判断不需要那么严格
    if ([[postList[row]objectForKey:@"ah"]count]==0) {
        return height+58;
    } else {
        return height+88;
    }
}
//
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(postList&&[postList count]) {
        NSLog(@"cell is deletable?!");
        return  UITableViewCellEditingStyleDelete;  //返回此值时,Cell会做出响应显示Delete按键,点击Delete后会调用下面的函数,别给传递UITableViewCellEditingStyleDelete参数
    } else {
        NSLog(@"cell is non-deletable?!");
        return  UITableViewCellEditingStyleNone;   //返回此值时,Cell上不会出现Delete按键,即Cell不做任何响应
    }
}

//删帖操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 如果UItableView对象请求的是删除操作。。。
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        if (postList&&[postList count]) {
            if ([Config Instance].isLogin==1) {
                if ([[postList[indexPath.row]objectForKey:@"perm_del"]integerValue]==1) {
                    
                    //初始化loadingHud
                    MBProgressHUD *loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
                    [self.view addSubview:loadingHud];
                    loadingHud.delegate=self;
                    loadingHud.labelText=@"删帖中..";
                    //初始化completedHud
                    MBProgressHUD *completedHud=[[MBProgressHUD alloc]initWithView:self.view];
                    [self.view addSubview:completedHud];
                    completedHud.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                    completedHud.mode=MBProgressHUDModeCustomView;
                    completedHud.delegate=self;
                    completedHud.labelText=@"删帖成功！";
                    
                    [loadingHud show:YES];
                    
                    [[DataManager manager] deletePostByBoard:boardName andFile:postTopicList[indexPath.row] success:^(NSDictionary *resultDict){
                        int success=[[resultDict objectForKey:@"success"]intValue];
                        if (success==1) {
                            [postList removeObjectAtIndex:indexPath.row];
                            [postTopicList removeObjectAtIndex:indexPath.row];

                            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                            
                            //马上隐藏loadingHud:
                            [loadingHud hide:YES afterDelay:0];
                            //提示登录成功:
                            [completedHud show:YES];
                            //停留1秒后消失
                            [completedHud hide:YES afterDelay:1.0];
                            
                        } else {
                            //马上隐藏loadingHud:
                            [loadingHud hide:YES afterDelay:0];
                            
                            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"删帖失败" message:@"稍后可再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [av show];
                        }
                    }failure:^(NSString *info, NSError *error){
                        // TODO: show the info
                        //NSLog(@"Failure: %@", operation.error);
                        //马上隐藏loadingHud:
                        [loadingHud hide:YES afterDelay:0];
                        
                        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [av show];
                        
                    }];
                    loadingHud=nil;
                    completedHud=nil;
                    
                } else {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你无权删除此帖！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
            }else if ([Config Instance].isLogin==0){
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你未登录，无权执行此操作！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
        }else{
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *btn = (UIButton *)sender;
    UITableViewCell *view = (UITableViewCell *)[[btn superview] superview];;
    //先判断系统版本，8.0以下系统会有不一样的表现(?):
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        view = (UITableViewCell *)[view superview];
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:view];
    
    if ([segue.identifier isEqualToString:@"replyPost"]) {
        AddPostViewController *addPostViewController=segue.destinationViewController;
        addPostViewController.type=@"reply";
        addPostViewController.boardName = self.boardName;
        if (postList&&[postList count]) {
            addPostViewController.titleStr = [self formatReplyingTitle:[postList[indexPath.row]objectForKey:@"title"]];
            addPostViewController.rawcontent = [NSString stringWithFormat:@"【在%@（%@）的大作中提到：】\n%@",[postList[indexPath.row]objectForKey:@"userid"],[postList[indexPath.row] objectForKey:@"username"],[self formatQuotingContent:[postList[indexPath.row] objectForKey:@"rawcontent"]]];
            //可选参数赋值空字符串：
            addPostViewController.articleid = [NSString stringWithFormat:@"%@",[postList[indexPath.row] objectForKey:@"filename"]];
            //发帖页面title:
            addPostViewController.viewTitleStr=@"评论";
        } else {
            addPostViewController.titleStr=@"";
            addPostViewController.rawcontent=@"";
            addPostViewController.articleid=@"";
            addPostViewController.viewTitleStr=@"出错了，请退回重新进入";
        }
        addPostViewController=nil;
    }
    if ([segue.identifier isEqualToString:@"showUserInfo"]) {
        UserQueryViewController *userQueryViewController=segue.destinationViewController;
        if (postList&&[postList count]) {
            userQueryViewController.userid=[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"userid"]];
            userQueryViewController.navigationItem.title=[NSString stringWithFormat:@"%@(%@)",[postList[indexPath.row]objectForKey:@"userid"],[postList[indexPath.row] objectForKey:@"username"]];
        } else {
            userQueryViewController.userid=@"";
            userQueryViewController.navigationItem.title=@"出错了，请退回重新进入";
        }
        userQueryViewController=nil;
    }
    
    if ([segue.identifier isEqualToString:@"showPicture"]) {
        
        AttachPictureViewController *attachPictureViewController=segue.destinationViewController;
        if (postList&&[postList count]) {
            attachPictureViewController.fileTimeStr=[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"post_time"]];
            attachPictureViewController.boardName=self.boardName;
        } else {
            attachPictureViewController.fileTimeStr=@"";
            attachPictureViewController.navigationItem.title=@"出错了，请退回重新进入";
        }
        attachPictureViewController=nil;
    }
    
    btn=nil;
    view=nil;
    indexPath=nil;
}

- (NSString*) formatReplyingTitle:(NSString*) originalTitle {
    NSString* format= ([originalTitle hasPrefix:@"Re: "] || [originalTitle hasPrefix:@"re: "])?@"%@":@"Re: %@";
    return [NSString stringWithFormat:format,originalTitle];
}

- (NSString*) formatQuotingContent:(NSString*) originalContent {
    NSLog(@"%@", originalContent);
    NSMutableString* formatedContent = [[NSMutableString alloc] init];
    NSArray* array=[originalContent componentsSeparatedByString:@"\n"];
    // The first and last line breakers shall be ignored.
    for (int iter = 1; iter < [array count]-1; ++iter) {
        if ([[array objectAtIndex:iter] hasPrefix:@": "])
            break;
        [formatedContent appendString:@": "];
        [formatedContent appendString:[array objectAtIndex:iter]];
        [formatedContent appendString:@"\n"];
    }
    return formatedContent;
}

@end
