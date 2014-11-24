//
//  SoftwareCatalog.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-3.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoftwareCatalog : NSObject

@property (nonatomic,copy) NSString * name;
@property int tag;

- (id)initWithParameters:(NSString *)newName andTag:(int)nTag;



@end
