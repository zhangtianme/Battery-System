//
//  LeftViewController.m
//  蓄电池系统
//
//  Created by 张天 on 2016/11/26.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "LeftViewController.h"
#import "SlideNavigationController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "Define.h"
#import "MemDataManager.h"
@interface LeftViewController ()<SlideNavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSUInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = themeColor;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = themeColor;
    _tableView.scrollEnabled = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedIndex = [MemDataManager shareManager].isIntranet;
}
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//   return 3;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
//    switch (section) {
//        case 0:
//            return 2;
//            break;
//        case 1:
//            return 1;
//            break;
//        default:
//            return 1;
//            break;
//    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = @"外网控制";
        cell.imageView.image = [UIImage imageNamed:@"网络.png"];
        cell.accessoryType = selectedIndex==0?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"内网控制";
        cell.imageView.image = [UIImage imageNamed:@"网络.png"];
        cell.accessoryType = selectedIndex==0?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    }
    else
    {
         cell.textLabel.text = indexPath.row==2?@"电池组配置":@"关于";
         cell.imageView.image = indexPath.row==2?[UIImage imageNamed:@"elecIcon.png"]:[UIImage imageNamed:@"关于.png"];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark -  tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *vc ;
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ((indexPath.row == 0||indexPath.row == 1) && selectedIndex!=indexPath.row) {
        selectedIndex = indexPath.row;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //外网模式断开所有socket连接
        if (indexPath.row == 0) {
            [[MemDataManager shareManager].groupArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BatteryGroup *group = obj;
                [group.socket disconnect];
            }];
        }
//        [batteryGroup.socket disconnect];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:indexPath.row] forKey:@"NetMode"];
    }
    if(indexPath.row == 2)
    {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NetSetting"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
    }
    if(indexPath.row == 3)
    {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"About"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
    }
}
@end
