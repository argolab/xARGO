//
//  LoadingCell.m
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-6.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

@synthesize normalStr,loadingStr,startViewStr,cell,label, indicator;

-(id)initWithNormalStr:(NSString*)_normalStr andLoadingStr:(NSString*)_loadingStr andStartViewStr:(NSString*)_startViewStr {
    
    startViewStr = _startViewStr;
    loadingStr = _loadingStr;
    normalStr = _normalStr;
    
    cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    //label设置
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, 240, 20)];
    
    label.center = cell.center;
    [label setTextAlignment:NSTextAlignmentCenter];
    label.font=[UIFont fontWithName:@"Arial" size:14];
    
    //indicator设置
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(70, 13, 20, 20);
    //indicator.center = CGPointMake(100, 20);
    
    [cell addSubview:label];
    [cell addSubview:indicator];
    
    [self normal];
    return self;
}

//正在加载数据中状态
-(void)loading {
    [indicator startAnimating];
    [label setText:loadingStr];
}

//加载完全部数据状态
-(void)startView {
    [indicator startAnimating];
    [label setText:startViewStr];
}

//加载更多状态
-(void)normal {
    [indicator stopAnimating];
     [label setText:normalStr];
}

@end
