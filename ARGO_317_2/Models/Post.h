//
//  Post.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property int _id;
@property int answerCount;
@property int viewCount;
@property (copy,nonatomic) NSString * title;
@property (copy,nonatomic) NSString * author;
@property int authorid;
@property (copy,nonatomic) NSString * fromNowOn;
@property (copy,nonatomic) NSString * img;
@property (retain,nonatomic) UIImage * imgData;
@property BOOL favorite;

- (id)initWithParameters:(int)newID
                andTitle:(NSString *)nTitle
               andAnswer:(int)newAnswerCount
                 andView:(int)newViewCount
               andAuthor:(NSString *)nauthor
             andAuthorID:(int)nAuthorID
            andFromNowOn:(NSString *)nfromNowOn
                  andImg:(NSString *)nimg;




@end
