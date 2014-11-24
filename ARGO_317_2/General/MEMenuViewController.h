//
//  ARGOAppDelegate.h
//  ARGO_317_2
//
//  Created by 490021684@qq.com on 14-3-17.
//  Copyright (c) 2014年 490021684@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface MEMenuViewController : UITableViewController
- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue;



@property (strong, nonatomic) IBOutlet UILabel *mail;


@property (strong, nonatomic) IBOutlet UILabel *message;


@end
