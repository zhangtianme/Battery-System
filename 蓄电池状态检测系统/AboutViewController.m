//
//  AboutViewController.m
//  蓄电池系统
//
//  Created by 张天 on 16/8/15.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
- (IBAction)dismissVC;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    _versionLabel.text = [NSString stringWithFormat:@"三川智能蓄电池管理系统 V%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
- (IBAction)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
