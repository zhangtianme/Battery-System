//
//  HealthListViewController.m
//  蓄电池系统
//
//  Created by 张天 on 2017/1/7.
//  Copyright © 2017年 张天. All rights reserved.
//

#import "HealthListViewController.h"
#import "Define.h"
#import "HBatteryListViewController.h"
#import "heartView.h"
@interface HealthListViewController ()
{
    NSArray *healthArray;
    NSDictionary *hDic;
}
@end

@implementation HealthListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电池状态";
    self.tableView.backgroundColor = matchColor;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        healthArray = [BatteryService InquirySubStatistics];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });

//    healthArray = [NSArray array];
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
       
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
              healthArray = [BatteryService InquirySubStatistics];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        });
        //加HUD
        [MBProgressHUD showMessage:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView headerEndRefreshing];
            [MBProgressHUD hideHUD];
        });
    }];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return healthArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HListCell"];
    cell.textLabel.text = healthArray[indexPath.section][@"HName"];
    cell.detailTextLabel.text = healthArray[indexPath.section][@"Number"];
//    heartView *heart = [[heartView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
//    heart.backgroundColor = [UIColor clearColor];
//    [cell.imageView addSubview:heart] ;
    if ([healthArray[indexPath.section][@"Number"] intValue] == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    hDic = healthArray[indexPath.section];
    [self performSegueWithIdentifier:@"HBList" sender:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HBatteryListViewController *vc = segue.destinationViewController;
    vc.hDic = hDic;
}
@end
