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
// 3. Rendering cells in page.
// 4. Scroll to the high water mark

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

static int pageSize = 10;

static NSString *CellIdentifier = @"postCell";

@implementation PostListViewController {
    int currentPage;
}
@synthesize boardName,fileName;
@synthesize postTopicList,postList;


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
    
    currentPage = 0;
    // Load list asynchously.
    [self initTopicList];
    UIRefreshControl *refresh=[[UIRefreshControl alloc]init];
    refresh.tintColor=[UIColor lightGrayColor];
    refresh.attributedTitle=[[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
}

-(void) initTopicList {
    postTopicList = [[NSMutableArray alloc]init];
    [loadingCell loading];
    [[DataManager manager] getPostsPerTopicByBoardName:boardName andFile:fileName success:^(NSDictionary *resultDict) {
        //NSLog(@"On getting topic successfully.");
        NSArray *data=[resultDict objectForKey:@"data"];
        //NSLog(@"Dictionary: %@", [data description]);
        postList = [NSMutableArray arrayWithCapacity:[data count]];
        for (int i=0; i<[data count]; i++) {
            if ([data objectAtIndex:i]) {
                [postList addObject:[NSNull null]];
                [postTopicList addObject:[data objectAtIndex:i]];
            }
        }
        [self loadUntilHighWaterMark];
    } failure:^(NSString *data, NSError *error) {
        // failed?
        NSLog(@"Loading failed.");
        NSString* errorMsg = NSLocalizedString([error.userInfo objectForKey:@"error"],@"");
        [loadingCell normal];
        loadingCell.label.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Reason:", @""), errorMsg];
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error",@"") message: [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Reason:", @""), errorMsg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
     ];
}

-(void) loadUntilHighWaterMark {
    [loadingCell loading];
    int highWaterMark = [[DataManager manager] getHighWaterMark:boardName andFile:fileName];
    [self fetchInBatch:0 numberOfPages:highWaterMark/pageSize + 1 didFinished:^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[DataManager manager] getHighWaterMark:boardName andFile:fileName] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
}

-(void) loadNextPage {
    [loadingCell loading];
    [self fetchInBatch:currentPage*pageSize numberOfPages:1 didFinished:nil];
}

//下拉刷新调用的方法
-(void)refreshView:(UIRefreshControl *)refresh {
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [self clear];
        [self initTopicList];
    }
}

- (void)clear {
    [postTopicList removeAllObjects];
    [loadingCell loading];
    currentPage = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Always there is a loading cell.
    return [self numberOfRows] + 1;
}

-(NSInteger) numberOfRows {
    return MIN(currentPage * pageSize, self.postTopicList.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if ([self numberOfRows] == indexPath.row) {
        // for the last row always return loading cell.
        return loadingCell.cell;
    }

    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *post = (self.postList)[indexPath.row];
    [self composite:cell at:indexPath with:post];
    [[DataManager manager] setHighWaterMark:boardName andFile:fileName mark:(int)indexPath.row];
    //NSLog(@"Returning cell=%@",cell);
    return cell;
}

-(void) fetchInBatch:(int) from numberOfPages:(int) num didFinished:(void (^) ())didFinished {
    assert(postTopicList.count > 0);
    assert(num >= 0);
    __block int counter = 0;
    int threshold = MIN(num*pageSize, (int)postTopicList.count - from);
    if (threshold < 0) {
        // No more data now.
        lastUpdated=[NSString stringWithFormat:@"更新时间 %@", [dateFormatter stringFromDate:[NSDate date]]];
        loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
    }
    //NSLog(@"Going to fetch next %d from %d", count, from);
    for (int i = from; i < from + threshold; ++i) {
        //NSLog(@"Going to fetch :%@", [postTopicList objectAtIndex:i]);
        [[DataManager manager] getPostByBoard:boardName andFile:[postTopicList objectAtIndex:i] forceReload:NO success:^(NSDictionary *resultDict) {
            //NSLog(@"On fetching successfully:%@",[[resultDict objectForKey:@"data"] objectForKey:@"filename"]);
            if ([resultDict objectForKey:@"data"]&&[[resultDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]]) {
                self.postList[i]=[resultDict objectForKey:@"data"];
            }
            ++counter;
            if(counter == threshold) {
                currentPage+=num;
                [loadingCell normal];
                if (postTopicList.count <= from + threshold) {
                    lastUpdated=[NSString stringWithFormat:@"更新时间 %@", [dateFormatter stringFromDate:[NSDate date]]];
                    loadingCell.label.text=[NSString stringWithFormat:@"%@",lastUpdated];
                } else {
                    loadingCell.label.text=[NSString stringWithFormat:@"下面还有%lu贴，轻轻上拉继续看",(unsigned long)postTopicList.count-from-threshold];
                }
                [self.tableView reloadData];
                if (didFinished) didFinished();
            }
        } failure:^(NSString *data, NSError *error) {
            NSLog(@"Failed when fetching post, data=%@, error=%@", data, error);
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"请退回重新进入或者重新登录后再试试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }];
    }
}

- (void) composite:(UITableViewCell *) cell at:(NSIndexPath *) indexPath
              with:(NSDictionary *) data {
    //NSLog(@"Compositing cell %@ at %@ with %@", cell, indexPath, data);
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
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //触发上拉加载更多的条件
    if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= -REFRESH_HEADER_HEIGHT && scrollView.contentOffset.y > 0) {
        //如果是提醒详情，则不需要上拉加载更多
        if ([self.navigationItem.title isEqualToString:@"提醒详情"]==NO) {
            if(currentPage*pageSize >= [self.postTopicList count]) {
                currentPage--;
                [self initTopicList];
            } else {
                [self loadNextPage];
            }
        }
    }
    
}

//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<[postList count] && postList[indexPath.row]!=[NSNull null]) {
        return [self getTheHeight:indexPath.row];
    } else {
        // System default 44.
        return 44;
    }
}

//计算行高
-(CGFloat) getTheHeight:(NSInteger)row {
    // 显示的内容
    NSString *rawcontentStr=[postList[row] objectForKey:@"rawcontent"];
    
    // 计算出高度
    CGSize size= [rawcontentStr sizeWithAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    CGFloat height=size.height;
    NSLog(@"height=%f", size.height);
    
    // textView上下constraint皆为25，此外UITextView上下padding各8，合计66.
    return height + 66;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(postList&&[postList count]) {
        //NSLog(@"cell is deletable?!");
        return  UITableViewCellEditingStyleDelete;  //返回此值时,Cell会做出响应显示Delete按键,点击Delete后会调用下面的函数,别给传递UITableViewCellEditingStyleDelete参数
    } else {
        //NSLog(@"cell is non-deletable?!");
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
    //NSLog(@"%@", originalContent);
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
