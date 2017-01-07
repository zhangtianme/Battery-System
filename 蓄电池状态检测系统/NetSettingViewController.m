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
{
    NSMutableArray *intranetGroups;
}
@end

@implementation NetSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.title = @"电池组配置";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
  
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(ensure:)];
    intranetGroups = [[NSUserDefaults standardUserDefaults] valueForKey:@"batteryIntranet"];
    if (intranetGroups == nil) {
        intranetGroups = [NSMutableArray array];
    }
    else
    {
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSDictionary *dic in intranetGroups) {
            BatteryGroup *group = [BatteryGroup new];
            group.name = dic[@"name"];
            group.ip = dic[@"ip"];
            group.port = [dic[@"port"] integerValue];
            group.address = [dic[@"address"] integerValue];
            [newArray addObject:group];
        }
        intranetGroups = newArray;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(ensure:)];
//            });
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(ensure) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = themeColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}
- (void)ensure{
    if (intranetGroups.count == 0) {
        if ([MemDataManager shareManager].isIntranet == NO) {
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"batteryIntranet"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"没有配置电池组将切换到外网模式" message:@"是否继续操作?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [MemDataManager shareManager].isIntranet = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeNet" object:nil];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"batteryIntranet"];
            [[MemDataManager shareManager] readPlist];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSites" object:nil];
            [self.navigationController popViewControllerAnimated:YES];

        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:ensureAction];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }

    
    
//    [self updateFromUI];
    NSMutableArray *saveArray = [NSMutableArray array];
    for (BatteryGroup *group in intranetGroups) {
        NSDictionary *dic = @{
                @"name":group.name,
                @"port":[NSString stringWithFormat:@"%d",group.port],
                @"ip":group.ip,
                @"address":[NSString stringWithFormat:@"%d",group.address]
        };
        [saveArray addObject:dic];
    }
    [[NSUserDefaults standardUserDefaults] setValue:saveArray forKey:@"batteryIntranet"];
    if ([MemDataManager shareManager].isIntranet == YES)
    {
        [[MemDataManager shareManager] readPlist];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSites" object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
//- (void)updateFromUI
//{
//    for (BatteryGroup *group in intranetGroups) {
//        for (int i = 0; i<4; i++) {
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:[intranetGroups indexOfObject:group]]];
//            UITextField *field = [cell.contentView viewWithTag:2];
//            switch (i) {
//                case 0:
//                    group.name = field.text;
//                    break;
//                case 1:
//                    group.ip = field.text;
//                    break;
//                case 2:
//                    group.port = field.text.integerValue;
//                    break;
//                case 3:
//                    group.address = field.text.integerValue;
//                    break;
//                default:
//                    break;
//            }
//            }
//        }
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return intranetGroups.count+1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section==intranetGroups.count?1:4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==intranetGroups.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }

        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        UIButton *btnCenter = [UIButton buttonWithType:UIButtonTypeSystem];
        btnCenter.tintColor = themeColor;
        [btnCenter setTitle:@"添加" forState:UIControlStateNormal];
        btnCenter.size = cell.contentView.size;
        btnCenter.center = CGPointMake(self.view.width/2, cell.contentView.height/2);
        [cell.contentView addSubview:btnCenter];
        [btnCenter addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GCell"];
    NSString *title,*key;
    switch (indexPath.row) {
        case 0:
            title = @"名称:";
            key = @"name";
            break;
        case 1:
            title = @"IP:";
            key = @"ip";
            break;
        case 2:
            title = @"端口:";
            key = @"port";
            break;
        case 3:
            title = @"地址:";
            key = @"address";
            break;
        default:
            break;
    }
    UILabel *textLabel = [cell.contentView viewWithTag:1];
    textLabel.text = title;
    NSArray *array = intranetGroups;
    BatteryGroup *group = array[indexPath.section];
    UITextField *valueField =[cell.contentView viewWithTag:2];
    [valueField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    if ([key isEqualToString:@"port"])
    {
        if (group.port == 0) {
            valueField.text = nil;
        }
        else
           valueField.text = [NSString stringWithFormat:@"%d",group.port];
    }
    else if ([key isEqualToString:@"address"])
    {
        if (group.address == 0) {
            valueField.text = nil;
        }
        else
        valueField.text = [NSString stringWithFormat:@"%d",group.address];
    }
//        [key isEqualToString:@"address"]) {
//        NSLog(@"%d",group.port);
//        if ([group valueForKey:key] == 0) {
//            valueField.text = nil;
//        }
//        else

    else
    {
       valueField.text = [group valueForKey:key];
    }
    return cell;
}
- (void)valueChanged:(UITextField *)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSUInteger section = [self.tableView indexPathForCell:cell].section;
    BatteryGroup *group = intranetGroups[section];
    NSUInteger row = [self.tableView indexPathForCell:cell].row;
        switch (row) {
            case 0:
                group.name = sender.text;
                break;
            case 1:
                group.ip = sender.text;
                break;
            case 2:
                group.port = sender.text.integerValue;
                break;
            case 3:
                group.address = sender.text.integerValue;
                break;
            default:
                break;
        }

}
- (void)add
{
    BatteryGroup *group = [BatteryGroup new];
    group.name = [NSString stringWithFormat:@"电池组%d",intranetGroups.count+1];
    group.port = 0;
    group.address = 0;
    group.ip = @"";
    [intranetGroups addObject:group];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:intranetGroups.count] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section==intranetGroups.count) {
        return [UIView new];
    }
    UIView *myHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    myHeader.backgroundColor = matchColor; // 淡蓝色背景色
    
    CGFloat width = 40;
    CGFloat height = 20;
    CGRect detailFrame  = CGRectMake(ScreenWidth-5-width, 0, width, height);
    CGFloat detailTextSize = 14;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:detailFrame];
    [btn setTitle:@"删除" forState:UIControlStateNormal];
//    btn.titleLabel.tintColor = [UIColor redColor];
//    btn.tintColor = [UIColor redColor];
     [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    btn.tag = section;
    btn.titleLabel.font = [UIFont systemFontOfSize:detailTextSize];

    [btn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    [myHeader addSubview:btn];
    myHeader.userInteractionEnabled = YES;
    return myHeader;

}
- (void)delete:(UIButton *)sender
{
    NSUInteger section = sender.tag;
    BatteryGroup *group = intranetGroups[section];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否删除%@？",group.name] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [intranetGroups removeObject:group];
        [self.tableView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:ensureAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // 从数据源中删除
//        NSMutableArray *array = [[MemDataManager shareManager] groupArray];
//        [array removeObjectAtIndex:indexPath.section];
//        // 从列表中删除
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}
@end
