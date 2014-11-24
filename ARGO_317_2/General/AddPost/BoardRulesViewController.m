//
//  BoardRulesViewController.m
//  xARGO
//
//  Created by 490021684@qq.com on 14-5-27.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import "BoardRulesViewController.h"

@interface BoardRulesViewController ()

@end

@implementation BoardRulesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backToAddPostView:(id)sender {
    
    //关闭页面
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:nil];

}
@end
