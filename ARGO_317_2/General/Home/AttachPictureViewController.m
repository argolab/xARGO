//
//  AttachPictureViewController.m
//  xARGO
//
//  Created by 490021684@qq.com on 14-5-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "AttachPictureViewController.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+LK.h"
#import "AddPostViewController.h"


@interface AttachPictureViewController ()

@end

@implementation AttachPictureViewController
@synthesize fileTimeStr,boardName;

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
    
    /*
    [self.attachPicture setClipsToBounds:YES];
    //[self.attachPicture setBounds:CGRectMake(0.0, 0.0, 320, CGFLOAT_MAX)];
    [self.attachPicture setContentMode:UIViewContentModeTopLeft];
     */
    
    [self downLoadImage];
}


-(void)downLoadImage
{
   /*
    NSString *urlStr=[NSString stringWithFormat:@"http://argo.sysu.edu.cn/attach/%@/%@",boardName,fileTimeStr];
    [self.attachPicture setImageWithURL:[NSURL URLWithString:urlStr]];
    urlStr=nil;
    */
    NSString *urlStr=[NSString stringWithFormat:@"http://argo.sysu.edu.cn/attach/%@/%@",boardName,fileTimeStr];
    NSURL *imageURL=[NSURL URLWithString:urlStr];
    __weak UIImageView *weakImageView = self.attachPicture;
    weakImageView.imageURL = imageURL;


}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"reportPicture"]){
        AddPostViewController *addPostViewController=segue.destinationViewController;
        
        addPostViewController.type=@"new";
        addPostViewController.titleStr=@"举报图片";
        addPostViewController.boardName=@"Complain";
        addPostViewController.rawcontent=[NSString stringWithFormat:@"我认为%@版filename为%@的图片违规，请求处理。",self.boardName,self.fileTimeStr];
        //可选参数赋值空字符串：
        addPostViewController.articleid=@"";
        //addPostViewController.attach=@"";
        //发帖页面title:
        addPostViewController.viewTitleStr=@"举报";
        
        
        //释放掉变量：
        addPostViewController=nil;
        
    }
    
}

@end
