//
//  AttachPictureViewController.h
//  xARGO
//
//  Created by 490021684@qq.com on 14-5-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachPictureViewController : UIViewController


//图片所属帖子的时间戳，通过这个来构建图片链接：/attach/$boardname/$filename
@property (nonatomic, strong) NSString *fileTimeStr;
@property (nonatomic, strong) NSString *boardName;

@property (strong, nonatomic) IBOutlet UIImageView *attachPicture;



@end
