//
//  PostListViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-27.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "TopicListViewController.h"
#import "PostListViewController.h"
#import "AddPostViewController.h"
#import "DataManager.h"


@interface TopicListViewController ()

@end

@implementation TopicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //navigationItem.title的下拉菜单：
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 100, self.navigationController.navigationBar.bounds.size.height);
        SINavigationMenuView *menu = [[SINavigationMenuView alloc] initWithFrame:frame title:self.theTitle];
        
        [menu displayMenuInView:self.tableView];
        menu.items = @[@"收藏本版",@"取消收藏"];
        menu.delegate = self;
        self.navigationItem.titleView = menu;
     }

    //初始化loadingHud
    loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loadingHud];
    loadingHud.delegate=self;
    loadingHud.labelText=@"loading..";
    
}


-(void) loadNextPage {
    if(isDataLoading || currentPage * pageSize >= totalNum) {
        [self didLoadNextPage];
        return;
    }
    NSInteger startNum = totalNum - (currentPage + 1) * pageSize - 1;
    isDataLoading = YES;
    [[DataManager manager] getTopicByBoardName:self.boardName andStartNum:startNum success:^(NSDictionary *resultDict) {
        NSArray* data=[resultDict objectForKey:@"data"];
        @synchronized(dataList) {
            for (NSInteger i = [data count] - 1; i >= 0; i--) {
                [dataList addObject:data[i]];
            }
        }
        isDataLoading=NO;
        [self.tableView reloadData];
        currentPage++;
        //记录下拉刷新时间：
        lastUpdated=[NSString stringWithFormat:@"上次更新时间 %@",
                     [dateFormatter stringFromDate:[NSDate date]]];
        [self didLoadNextPage];
    } failure:^(NSString *data, NSError *error) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"error" message:@"请重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self didLoadNextPage];
    }];
}
//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<[dataList count]) {
        return [self getTheHeight:indexPath.row];
    } else {
        return 50;
    }
}

//计算行高
-(CGFloat) getTheHeight:(NSInteger)row {
    // 显示的内容
    NSString *titleStr=[NSString stringWithFormat:@"%@（%ld）",[dataList[row]objectForKey:@"title"],(long)[[dataList[row]objectForKey:@"total_reply"]integerValue]+1];
    
    // 计算出高度
    NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize size=[titleStr boundingRectWithSize:CGSizeMake(295,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        CGFloat height=size.height;

    // 返回需要的高度,这里的判断不需要那么严格
    return height+30;
    
}

-(void) loadTotalNum {
    // 获取total_topicNum参数
    [[DataManager manager] getBoardByBoardName:self.boardName success:^(NSDictionary *data){
        NSLog(@"Dictionary: %@", [data description]);
        
        totalNum=[[[data objectForKey:@"data"] objectForKey:@"total_topic"]integerValue];
        [self didLoadTotalNum];
    } failure: ^(NSString *data, NSError *error){
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:[error localizedDescription]
                           delegate:nil cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [av show];
    }];
}

- (void) composite:(UITableViewCell *) cell at:(NSIndexPath *) indexPath
              with:(NSDictionary *) data {
    NSString *titleStr=@"loading..";
    NSString *ownerStr=@"loading..";
    NSString *updateTimeStr=@"loading..";
    titleStr = [self formatCellTitle: data];
    
    ownerStr = [NSString stringWithFormat:@"%@",[data objectForKey:@"owner"]];
    
    updateTimeStr = [self timeDescipFrom:[[data objectForKey:@"update"]doubleValue]];
    
    ((UILabel *)[cell.contentView viewWithTag:1]).text=titleStr;
    ((UILabel *)[cell.contentView viewWithTag:2]).text=ownerStr;
    ((UILabel *)[cell.contentView viewWithTag:3]).text=updateTimeStr;
}

-(NSString *) formatCellTitle:(NSDictionary *) post {
    long replies = [[post objectForKey:@"total_reply"] integerValue];
    if (replies == 0)
        return [NSString stringWithFormat:@"%@",[post objectForKey:@"title"]];
    else
        return [NSString stringWithFormat:@"%@（%ld）",[post objectForKey:@"title"], replies];
}

//收藏版面,采用协议方法：
- (void)didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"did selected item at index %lu", (unsigned long)index);
    
    if ([Config Instance].isLogin==YES) {
        
        [loadingHud show:YES];
        
        if (index==0) {
            
            NSString *urlString=@"http://argo.sysu.edu.cn/ajax/user/addfav";
            
            NSDictionary *param=@{@"boardname":self.boardName};
            
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
            
            NSDictionary *param=@{@"boardname":self.boardName};
            
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showPostViewFromPostListView"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PostListViewController *postViewController= segue.destinationViewController;
        
        postViewController.boardName=self.boardName;
        if (dataList&&[dataList count]) {
            postViewController.fileName=[dataList[indexPath.row]objectForKey:@"filename"];
            postViewController.navigationItem.title=[NSString stringWithFormat:@"%@",[dataList[indexPath.row]objectForKey:@"title"]];
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
    }
    
}


@end
