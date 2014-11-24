//
//  Comment.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject


@property int _id;
@property (copy,nonatomic) NSString * img;
@property (retain,nonatomic) UIImage * imgData;
@property (copy,nonatomic) NSString * author;
@property int authorid;
@property (copy,nonatomic) NSString * content;
@property (copy,nonatomic) NSString * pubDate;
@property (retain,nonatomic) NSMutableArray * replies;
@property (retain,nonatomic) NSMutableArray * refers;
@property int appClient;
@property int catalog;
@property int parentID;
@property int height;
@property int height_reference;
@property float width_bubble;

- (id)initWithParameters:(int)nid
                  andImg:(NSString *)nimg
               andAuthor:(NSString *)nauthor
             andAuthorID:(int)nauthorid
              andContent:(NSString *)nContent
              andPubDate:(NSString *)nPubDate
              andReplies:(NSMutableArray *)array
               andRefers:(NSMutableArray *)nrefers
            andAppClient:(int)nappclient;







@end
