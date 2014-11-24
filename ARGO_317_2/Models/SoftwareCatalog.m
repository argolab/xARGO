//
//  SoftwareCatalog.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "SoftwareCatalog.h"

@implementation SoftwareCatalog

@synthesize name;
@synthesize tag;

- (id)initWithParameters:(NSString *)newName andTag:(int)nTag
{
    SoftwareCatalog *s = [[SoftwareCatalog alloc] init];
    s.name = newName;
    s.tag = nTag;
    return s;
}


@end
