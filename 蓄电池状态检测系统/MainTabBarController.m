//
//  MainTabBarController.m
//  蓄电池系统
//
//  Created by 张天 on 2016/11/26.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "MainTabBarController.h"
#import "SlideNavigationController.h"
@interface MainTabBarController ()<SlideNavigationControllerDelegate>

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


@end
