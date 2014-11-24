//
//  LoadingCell.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-4-6.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//  一个NSObject子类，持有一个UITableViewCell的对象引用，并向外开放几个方法（normal,loading,loadingFinshed)来控制当前显示状态

#import <Foundation/Foundation.h>

@interface LoadingCell : NSObject
{
    UITableViewCell *cell;
    UIActivityIndicatorView *indicator;
    UILabel *label;
}


//@property (nonatomic, strong) IBOutlet UITableViewCell *cell;

//不同的状态对应的不同文本描述
@property (nonatomic, strong) NSString *normalStr;
@property (nonatomic, strong) NSString *loadingStr;
@property (nonatomic, strong) NSString *startViewStr;//tableview开始时提示用户正在加载数据，下拉可以刷新
@property (nonatomic, strong) UITableViewCell *cell;

@property (nonatomic, strong) UILabel *label;





//初始化方法，设置状态文本
-(id)initWithNormalStr:(NSString*)_normalStr andLoadingStr:(NSString*)_loadingStr andStartViewStr:(NSString*)_startViewStr;

-(void)normal; //"加载更多"
-(void)startView; //"数据已全部加载完成"
-(void)loading; //"数据加载中"





@end
