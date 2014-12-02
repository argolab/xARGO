//
//  PostListViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-27.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "PostListViewController.h"
#import "PostViewController.h"
#import "AddPostViewController.h"



@interface PostListViewController ()

@end

@implementation PostListViewController
@synthesize refreshControl;
@synthesize boardName,postListPage,postList,loadingCell,total_topicNum,boardTitle;
@synthesize _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // 初始化参数：
        currPage=0;
        postListPage=[[NSMutableArray alloc]initWithCapacity:20];
     }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (animated) {
        [self fetchTotal_topicNumWithBoardName:boardName];
    }
}

//获取total_topicNum参数
- (void)fetchTotal_topicNumWithBoardName:(NSString *)boardname
{
    
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/board/get";
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardname}];
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        //NSLog(@"success------------------------>%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"resultDict------------------>%@",resultDict);
        NSDictionary *board=[resultDict objectForKey:@"data"];
        total_topicNum=[[board objectForKey:@"total_topic"]integerValue];
        NSLog(@"total_topicNum----------->%ld",(long)total_topicNum);
        
        //记录下拉刷新时间：
        lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                     [dateFormatter stringFromDate:[NSDate date]]];

        
        //释放用完的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        board=nil;
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        //NSLog(@"Failure: %@", operation.error);
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    //navigationItem.title的下拉菜单：
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 100, self.navigationController.navigationBar.bounds.size.height);
        SINavigationMenuView *menu = [[SINavigationMenuView alloc] initWithFrame:frame title:boardTitle];
        
        [menu displayMenuInView:self.view];
        menu.items = @[@"收藏本版",@"取消收藏"];
        menu.delegate = self;
        self.navigationItem.titleView = menu;
     }

    
    //初始化loadingCell等实例变量：
    loadingCell=[[LoadingCell alloc]initWithNormalStr:@"上拉加载更多" andLoadingStr:@"数据加载中.." andStartViewStr:@"可下拉刷新"];
    dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd, HH:mm"];
    lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                 [dateFormatter stringFromDate:[NSDate date]]];
    isDataReady=YES;
    
    //设置分隔线样式
    _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;


    //获取total_topicNum参数
    //[self fetchTotal_topicNumWithBoardName:boardName];
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
    currPage = 0;
    if (postList) {
        [postList removeAllObjects];
    }
    total_topicNum=0;
    isDataReady=YES;
    [self fetchTotal_topicNumWithBoardName:boardName];
    [loadingCell loading];
    
    [_tableView reloadData];
}


//收藏版面,采用协议方法：
- (void)didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"did selected item at index %lu", (unsigned long)index);
    
    if ([Config Instance].isLogin==YES) {
        
        [loadingHud show:YES];
        
        if (index==0) {
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/user/addfav";
            
            NSDictionary *param=@{@"boardname":boardName};
            
            [[AFHTTPRequestOperationManager manager] POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject){
                
                //NSLog(@"success------------------------>%@",operation.responseObject);
                NSString *requestTmp = [NSString stringWithString:operation.responseString];
                NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                //系统自带JSON解析：
                NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                //NSLog(@"resultDict------------------>%@",resultDict);
                
                int success=[[resultDict objectForKey:@"success"]intValue];
                if (success==1) {
                    
                    [loadingHud hide:YES];
                    
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"收藏成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    
                }else{
                    
                    [loadingHud hide:YES];
                    
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"收藏失败" message:@"请重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                
                //释放掉已经用过的变量：
                requestTmp=nil;
                resData=nil;
                resultDict=nil;
                
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
                [loadingHud hide:YES];
                
                //NSLog(@"Failure: %@", operation.error);
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }];
        }else{
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/user/delfav";
            
            NSDictionary *param=@{@"boardname":boardName};
            
            [[AFHTTPRequestOperationManager manager] POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject){
                
                //NSLog(@"success------------------------>%@",operation.responseObject);
                NSString *requestTmp = [NSString stringWithString:operation.responseString];
                NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
                //系统自带JSON解析：
                NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
                //NSLog(@"resultDict------------------>%@",resultDict);
                
                int success=[[resultDict objectForKey:@"success"]intValue];
                if (success==1) {
                    
                    [loadingHud hide:YES];
                    
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"取消收藏成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    
                }else{
                    
                    [loadingHud hide:YES];
                    
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"操作失败" message:@"请重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                
                //释放掉已经用过的变量：
                requestTmp=nil;
                resData=nil;
                resultDict=nil;
                
            }failure:^(AFHTTPRequestOperation *operation, NSError *error){
                
                [loadingHud hide:YES];
                
                //NSLog(@"Failure: %@", operation.error);
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                
            }];
            
        }
        
    }else if ([Config Instance].isLogin==NO){
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"操作失败" message:@"登录后才能执行这个操作哦" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
}


-(void)loadData
{
    [loadingCell loading];
    if (isDataReady) {
        isDataReady=NO;
        currPage++;
        //NSLog(@"total_topicNum-------------->%ld",(long)total_topicNum);
        NSInteger startNum;
        if (total_topicNum==0) {
            startNum=total_topicNum-(currPage-1)*pageSize;
        }else{
            startNum=total_topicNum-currPage*pageSize+1;
        }
        
        //NSLog(@"startNum-------------->%ld",(long)startNum);
        [self fetchServerDataFromStartNum:startNum];
        //添加适当的时延，增强用户感知。
        //[self performSelector:@selector(hideForWhat) withObject:nil afterDelay:0];
    }
}

-(void)fetchServerDataFromStartNum:(NSInteger)startNum
{
    
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/post/list";
    NSNumber *startNumber=[NSNumber numberWithInteger:startNum];
    NSMutableDictionary *param=[[NSMutableDictionary alloc]initWithDictionary:@{@"boardname":boardName,@"type":@"topic",@"start":startNumber}];
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        //NSLog(@"success------------------------>%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        //NSLog(@"resultDict------------------>%@",resultDict);
        
        int success=[[resultDict objectForKey:@"success"]intValue];
        if (success==1) {
            
            postListPage=[resultDict objectForKey:@"data"];
            
            //释放掉用过的变量：
            requestTmp=nil;
            resData=nil;
            resultDict=nil;
            
            //NSLog(@"postListPage------------------>%@",postListPage);
            /*
             for (NSDictionary *post in postListPage) {
             [postList addObject:post];
             }
             */
            //采用倒排取数,这里不知道会不会造成内存泄露，后续再修改
            for (NSInteger i=[postListPage count]-1; i>=0; i--) {
                if ([postListPage objectAtIndex:i]&&[[postListPage objectAtIndex:i]isKindOfClass:[NSDictionary class]]) {
                    [postList addObject:[postListPage objectAtIndex:i]];
                }
            }
            
            isDataReady=YES;
            [self._tableView reloadData];
            [loadingCell normal];

            
            //NSLog(@"postList------------------>%@",postList);
            
        }else{
            
            isDataReady=YES;
            
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"error" message:@"请重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
        
        //设置分隔线正常
        _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;


     }failure:^(AFHTTPRequestOperation *operation, NSError *error){
         
         isDataReady=YES;
         
         //设置分隔线正常
         _tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;

        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
    }];
}

/*
- (void)hideForWhat
{
    [loadingCell normal];
    
    [self._tableView reloadData];
 }
 */


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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postListCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"postListCell"];
    }

    if (indexPath.row <[postList count]) {
        
        NSString *titleStr=@"loading..";
        NSString *ownerStr=@"loading..";
        NSString *updateTimeStr=@"loading..";
        
        if (postList&&[postList count]) {
            titleStr=[NSString stringWithFormat:@"%@（%ld）",[postList[indexPath.row]objectForKey:@"title"],(long)[[postList[indexPath.row]objectForKey:@"total_reply"]integerValue]+1];

            ownerStr=[NSString stringWithFormat:@"%@",[postList[indexPath.row]objectForKey:@"owner"]];

            updateTimeStr=[self timeDescipFrom:[[postList[indexPath.row]objectForKey:@"update"]doubleValue]];
        }
        
        ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
        
        ((UILabel *)[cell.contentView viewWithTag:2]).text=ownerStr;
        
        ((UILabel *)[cell.contentView viewWithTag:3]).text=updateTimeStr;
        
        
        titleStr=nil;
        ownerStr=nil;
        updateTimeStr=nil;
        
        
        return cell;

    }else{
        //最后一项，加载更多
        return loadingCell.cell;
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



/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostViewController *postViewController=[[PostViewController alloc]init];
    [[self navigationController]pushViewController:postViewController animated:YES];
    [[postViewController navigationItem]setTitle:[postListData.postListItems.postList[indexPath.row]objectForKey:@"title"]];
    postViewController.boardName=self.boardName;
    postViewController.fileName=[self.postListData.postListItems.postList[indexPath.row]objectForKey:@"filename"];
    //NSLog(@"postViewController.fileName------------------->%@",postViewController.fileName);
    //NSLog(@"postViewController.boardName------------------->%@",postViewController.boardName);
    postViewController=nil;

}
 */



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showPostViewFromPostListView"]) {
        NSIndexPath *indexPath = [self._tableView indexPathForSelectedRow];
        PostViewController *postViewController= segue.destinationViewController;
        
        postViewController.boardName=self.boardName;
        if (postList&&[postList count]) {
            postViewController.fileName=[self.postList[indexPath.row]objectForKey:@"filename"];
            postViewController.navigationItem.title=[NSString stringWithFormat:@"%@",[self.postList[indexPath.row]objectForKey:@"title"]];
        }else{
            postViewController.fileName=@"";
            postViewController.navigationItem.title=@"请退回重新进入";
        }
        
        postViewController=nil;//important!否则如果持续使用会导致内存被塞满
        indexPath=nil;
        
    }else if ([segue.identifier isEqualToString:@"addNewPost"]){
        
        AddPostViewController *addPostViewController=segue.destinationViewController;
        
        addPostViewController.type=@"new";
        addPostViewController.titleStr=@"";
        addPostViewController.boardName=self.boardName;
        addPostViewController.rawcontent=@"";
        //可选参数赋值空字符串：
        addPostViewController.articleid=@"";
        //addPostViewController.attach=@"";
        //发帖页面title:
        addPostViewController.viewTitleStr=@"发帖";
        
        
        //释放掉变量：
        addPostViewController=nil;
        
    }
    
}


@end
