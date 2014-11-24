//
//  Post.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "Post.h"

@implementation Post

@synthesize _id;
@synthesize answerCount;
@synthesize viewCount;
@synthesize title;
@synthesize author;
@synthesize authorid;
@synthesize fromNowOn;
@synthesize img;
@synthesize imgData;
@synthesize favorite;

- (id)initWithParameters:(int)newID
                andTitle:(NSString *)nTitle
               andAnswer:(int)newAnswerCount
                 andView:(int)newViewCount
               andAuthor:(NSString *)nauthor
             andAuthorID:(int)nAuthorID
            andFromNowOn:(NSString *)nfromNowOn
                  andImg:(NSString *)nimg
{
    Post *p = [[Post alloc] init];
    p._id = newID;
    p.title = nTitle;
    p.answerCount = newAnswerCount;
    p.viewCount = newViewCount;
    p.author = nauthor;
    p.authorid = nAuthorID;
    p.fromNowOn = nfromNowOn;
    p.img = nimg;
    return p;
}


@end
