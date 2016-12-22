//
//  NetSettingViewController.m
//  蓄电池系统
//
//  Created by 张天 on 16/8/18.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "NetSettingViewController.h"
#import "Define.h"
#import "MemDataManager.h"
@interface NetSettingViewController ()

@end

@implementation NetSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
     self.title = @"电池组配置";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(ensure:)];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}
- (void)ensure:()sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *array = [[MemDataManager shareManager] groupArray];
    return array.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GCell"];
    NSString *title,*key;
    switch (indexPath.row) {
        case 0:
            title = @"名称：";
            key = @"name";
            break;
        case 1:
            title = @"IP：";
            key = @"ip";
            break;
        case 2:
            title = @"端口：";
            key = @"port";
            break;
        default:
            break;
    }
    UILabel *textLabel = [cell.contentView viewWithTag:1];
    textLabel.text = title;
    NSArray *array = [[MemDataManager shareManager] groupArray];
    BatteryGroup *group = array[indexPath.section];
    UITextField *valueField =[cell.contentView viewWithTag:2];
    if ([key isEqualToString:@"port"]) {
        valueField.text = [NSString stringWithFormat:@"%d",group.port];
    }
    else
    {
       valueField.text = [group valueForKey:key];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 从数据源中删除
        NSMutableArray *array = [[MemDataManager shareManager] groupArray];
        [array removeObjectAtIndex:indexPath.section];
        // 从列表中删除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
