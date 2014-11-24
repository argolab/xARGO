//
//  Config.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "SoftwareCatalog.h"


@interface Config : NSObject



//是否已经登录
@property BOOL isLogin;

@property (retain, nonatomic) UIViewController * viewBeforeLogin;
@property (copy, nonatomic) NSString * viewNameBeforeLogin;

//是否具备网络链接
@property BOOL isNetworkRunning;

@property (retain, nonatomic) SoftwareCatalog * singleSoftwareCatalog;


//保存登录用户名以及密码
-(void)saveUserNameAndPwd:(NSString *)userName andPwd:(NSString *)pwd;
-(NSString *)getUserName;
-(NSString *)getPwd;
-(void)saveUID:(int)uid;
-(int)getUID;
-(void)savePostPubNoticeMe:(BOOL)isNotice;
-(BOOL)isPostPubNoticeMe;
-(void)saveCookie:(BOOL)_isLogin;
-(BOOL)isCookie;

-(void)saveIsPostToMyZone:(BOOL)isToMyZone;
-(BOOL)getIsPostToMyZone;

-(void)savePubPostCatalog:(int)catalog;
-(int)getPubPostCatalog;

-(NSString *)getIOSGuid;

+(Config *) Instance;
+(id)allocWithZone:(NSZone *)zone;


@end
