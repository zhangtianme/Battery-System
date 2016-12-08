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
    selectedIndex = [defaultBatteryIndex integerValue];
}
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"2V电池组";
            cell.imageView.image = [UIImage imageNamed:@"elecIcon.png"];
            cell.accessoryType = selectedIndex==0?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }
        else
        {
            cell.textLabel.text = @"12V电池组";
            cell.imageView.image = [UIImage imageNamed:@"elecIcon.png"];
            cell.accessoryType = selectedIndex==0?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
        }
     
        
    }
    else
    {
         cell.textLabel.text = indexPath.section==1?@"网络配置":@"关于";
         cell.imageView.image = indexPath.section==1?[UIImage imageNamed:@"网络.png"]:[UIImage imageNamed:@"关于.png"];
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
    if (indexPath.section == 0 && selectedIndex!=indexPath.row) {
        selectedIndex = indexPath.row;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //取出对象
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        BatteryGroup *batteryGroup = appDelegate.batteryGroup;
        [batteryGroup.socket disconnect];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lu",(unsigned long)selectedIndex] forKey:@"BatteryIndex"];
    }
    else if(indexPath.section == 1)
    {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NetSetting"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
    }
    else if(indexPath.section == 2)
    {
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"About"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
    }
}
@end
