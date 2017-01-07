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
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNet) name:@"ChangeNet" object:nil];
}
- (void)changeNet
{
    selectedIndex = [MemDataManager shareManager].isIntranet;
//    [_tableView reloadData];
  [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(145, 0, 44, 44)];
        btn.tag = 1;
        [cell.contentView addSubview:btn];
        [btn setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = selectedIndex==0?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 1)
    {
        if ([cell.contentView viewWithTag:1]) {
            [[cell.contentView viewWithTag:1] removeFromSuperview];
        }
        cell.textLabel.text = @"内网控制";
        cell.imageView.image = [UIImage imageNamed:@"网络.png"];
        cell.accessoryType = selectedIndex==0?UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
    }
    else
    {
        if ([cell.contentView viewWithTag:1]) {
            [[cell.contentView viewWithTag:1] removeFromSuperview];
        }
         cell.textLabel.text = indexPath.row==2?@"内网配置":@"关于";
         cell.imageView.image = indexPath.row==2?[UIImage imageNamed:@"elecIcon.png"]:[UIImage imageNamed:@"关于.png"];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}
- (void)refresh:(UIButton *)sender
{
    //更新站点信息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array = [BatteryService inquiryPack];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (array) {
                [[MemDataManager shareManager] updateGroupData:array];
            }
        });
    });
    [self rotate360DegreeWithImageView:sender.imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender.imageView.layer removeAllAnimations];
    });
}
- (void)rotate360DegreeWithImageView:(UIImageView *)imageView {
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         CATransform3DMakeRotation(M_PI/2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.4;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 16;
    animation.removedOnCompletion = YES;
    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [imageView.image drawInRect:imageRrect];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [imageView.layer addAnimation:animation forKey:nil ];
}
#pragma mark -  tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UIViewController *vc ;
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ((indexPath.row == 0||indexPath.row == 1) && selectedIndex!=indexPath.row) {
        //判断是否有局域网电池配置
        if (indexPath.row == 1) {
            if([[NSUserDefaults standardUserDefaults] valueForKey:@"batteryIntranet"] == nil)
            {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"当前没有内网电池组配置" message:@"是否前往配置？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NetSetting"];
                    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                             withSlideOutAnimation:YES
                                                                                     andCompletion:nil];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    }];
                [alertVC addAction:ensureAction];
                [alertVC addAction:cancelAction];
                
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
                return;
            }
        }
        
        selectedIndex = indexPath.row;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //外网模式断开所有socket连接
        if (indexPath.row == 0) {
            [[MemDataManager shareManager].groupArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BatteryGroup *group = obj;
                [group.socket disconnect];
            }];
        }
//        [batteryGroup.socket disconnect];
        [MemDataManager shareManager].isIntranet = indexPath.row;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetMode" object:nil];
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
