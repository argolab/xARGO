//
//  MailDetailViewController.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "MailDetailViewController.h"
#import "SendMailViewController.h"

@interface MailDetailViewController ()

@end

@implementation MailDetailViewController
@synthesize mailIndex,mailDetail;

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
    mailDetail=[[NSDictionary alloc]init];
    //初始化loadingHud
    loadingHud=[[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:loadingHud];
    loadingHud.delegate=self;
    loadingHud.labelText=@"数据加载中";

    [self fetchMailDetailFromServerWith:mailIndex];
    
}

-(void)fetchMailDetailFromServerWith:(NSInteger)index
{
    [loadingHud show:YES];
    
    //NSLog(@"mailIndex--------------->%ld",(long)mailIndex);
    NSString *urlString=@"http://argo.sysu.edu.cn/ajax/mail/get";
    
    NSNumber *indexNumber=[NSNumber numberWithInteger:index];
    
    NSDictionary *param=@{@"index": indexNumber};
    
    [[AFHTTPRequestOperationManager manager] GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"operation.responseObject---------------->%@",operation.responseObject);
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        NSData *resData=[[NSData alloc]initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析：
        NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        
        //NSLog(@"mailDetail_resultDict-------------->%@",resultDict);
        mailDetail=[resultDict objectForKey:@"data"];
        
        self.mailTitle.text=[NSString stringWithFormat:@"标题：%@",[mailDetail objectForKey:@"title"]];
        self.mailContent.text=[NSString stringWithFormat:@"%@",[mailDetail objectForKey:@"content"]];
        
        
        [self.tableView reloadData];
        [loadingHud hide:YES];

        //释放掉用过的变量：
        requestTmp=nil;
        resData=nil;
        resultDict=nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [loadingHud hide:YES];
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}



//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getTheHeight:indexPath.row];
}

//计算行高
-(CGFloat) getTheHeight:(NSInteger)row
{
    if (row==0) {
        NSString *str=[NSString stringWithFormat:@"标题：%@",[mailDetail objectForKey:@"title"]];
        // 计算出高度
        NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        CGSize size=[str boundingRectWithSize:CGSizeMake(280,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        CGFloat height=size.height;
        
        //释放内存：
        str=nil;
        attribute=nil;
        
        // 返回需要的高度
        return height+20;

    }else{
        NSString *str=[NSString stringWithFormat:@"%@",[mailDetail objectForKey:@"content"]];
        // 计算出高度
        NSDictionary *attribute=@{NSFontAttributeName: [UIFont systemFontOfSize:14]};
        CGSize size=[str boundingRectWithSize:CGSizeMake(280,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        CGFloat height=size.height;
        
        //释放内存：
        str=nil;
        attribute=nil;
        
        // 返回需要的高度
        return height+30;

    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"replyMailFromMailDetailView"]) {
        
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        SendMailViewController *sendMailViewController= segue.destinationViewController;
        
        sendMailViewController.mailTitleStr=[NSString stringWithFormat:@"回复：%@",[mailDetail objectForKey:@"title"]];
        
        sendMailViewController.receiverStr=[NSString stringWithFormat:@"%@",[mailDetail objectForKey:@"owner"]];
        
        sendMailViewController.contentStr=[NSString stringWithFormat:@"\n\n------------\n%@",[mailDetail objectForKey:@"content"]];
        
        
        sendMailViewController=nil;
    }
}



@end
