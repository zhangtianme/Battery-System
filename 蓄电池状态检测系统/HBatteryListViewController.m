//
//  HBatteryListViewController.m
//  蓄电池系统
//
//  Created by 张天 on 2017/1/7.
//  Copyright © 2017年 张天. All rights reserved.
//

#import "HBatteryListViewController.h"
#import "Define.h"
@interface HBatteryListViewController ()
{
    NSArray *batteryArray;
    NSArray *displayArray;
}
@end

@implementation HBatteryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    displayArray = @[@{@"title":@"站点名称",@"key":@"BName"},
                             @{@"title":@"电池编号",@"key":@"Number"},
                             @{@"title":@"健康状态",@"key":@"Fore_Health"}
                             ];
    self.title = [_hDic[@"HName"] stringByAppendingString:@"电池"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        batteryArray = [BatteryService InquirySubList:_hDic[@"HID"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            batteryArray = [BatteryService InquirySubList:_hDic[@"HID"]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return batteryArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return displayArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HBCell"];
    NSDictionary *bDic = batteryArray[indexPath.section];
    NSDictionary *rowDic = displayArray[indexPath.row];
    cell.textLabel.text = rowDic[@"title"];
    cell.detailTextLabel.text = bDic[rowDic[@"key"]];
    if (indexPath.row == 2) {
        cell.detailTextLabel.text = [bDic[rowDic[@"key"]] stringByAppendingString:@"%"];
    }
    return cell;
}

@end
