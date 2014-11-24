//
//  AddPostViewController.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-13.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"


@interface AddPostViewController : UIViewController<MBProgressHUDDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    MBProgressHUD *loadingHud;
    MBProgressHUD *completedHud;

    //param参数：
    NSString *type;//type: new | reply | update
    NSString *boardName;
    NSString *articleid;//（可选）回帖时所回复帖子的filename（type = reply时有用)
    NSString *titleParam;//帖子主题
    NSString *content;//帖子内容
    NSData *attach;//附件（可选）
    
    //假如是回帖，从上一个view中传递过来的content
    NSString *titleStr;
    NSString *rawcontent;
}

@property (strong, nonatomic)NSString *type;
@property (strong, nonatomic)NSString *boardName;
@property (strong, nonatomic)NSString *articleid;
@property (strong, nonatomic)NSString *titleParam;
@property (strong, nonatomic)NSString *content;
@property (strong, nonatomic)NSData *attach;

@property (strong, nonatomic)NSString *titleStr;
@property (strong, nonatomic)NSString *rawcontent;

@property (strong, nonatomic)NSString *viewTitleStr;



@property (strong, nonatomic) IBOutlet UITextField *titleTextField;


@property (strong, nonatomic) IBOutlet UITextView *contentTextView;


@property (strong, nonatomic) IBOutlet UILabel *viewTitle;


- (IBAction)cancel_Click:(id)sender;


- (IBAction)addPost_Click:(id)sender;

- (IBAction)takePicture:(id)sender;


//提示登录

@property (strong, nonatomic) IBOutlet UILabel *loginAlert;

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;


//是否附图提示：


@property (strong, nonatomic) IBOutlet UIImageView *isAttachMark;



@end
