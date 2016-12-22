//
//  ReferenceViewController.m
//  蓄电池系统
//
//  Created by zhang tian on 16/8/11.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "ReferenceViewController.h"
#import "Define.h"
#define HIS_COUNT 9

@interface ReferenceViewController ()<BatteryManagerDelegate>
{
    MBProgressHUD *mbHud;
    NSMutableArray *referenceArray;
}
@end

@implementation ReferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    referenceArray = [NSMutableArray array];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.title = @"参考值";
    if (!mbHud) {
        mbHud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:mbHud];
        mbHud.dimBackground = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BatteryManager shareManager] setDelegate:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return section==0?1:referenceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }
        cell.textLabel.text = @"参考值";
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.imageView.image = [UIImage imageNamed:@"operation"];
        //添加2个button
        for (int i=0; i<2; i++) {
            UIGlossyButton *btn = [[UIGlossyButton alloc] init];
            [btn setNavigationButtonWithColor:themeColor];
            //                btn.buttonBorderWidth = 2.0;
            btn.borderColor = [UIColor whiteColor];
            btn.frame = CGRectMake(0, 0, 50, 35);
            float singleWith = ScreenWidth/5;
            float btnX = singleWith*(i+3.5);
            float btnY = 22;
            btn.center = CGPointMake(btnX, btnY);
            //            NSString *start = NSLocalizedString(@"start", nil);
            //            NSString *stop = NSLocalizedString(@"stop", nil);
            NSString *start = @"读取";
            NSString *stop = @"设定";
            [btn setTitle:i==0?start:stop forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            //                btn.titleLabel.textColor = [UIColor blackColor];
            btn.tag = i+1;
            [btn addTarget:self action:@selector(controlBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
        }
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NormalCell"];
    }
    NSDictionary *dic = referenceArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  SOHO:%@  V0:%@  R0:%@",dic[@"time"],dic[@"soho"],dic[@"voltage"],dic[@"res"]];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *myHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    myHeader.backgroundColor = matchColor; // 淡蓝色背景色
    CGFloat width = myHeader.frame.size.width;
    CGFloat height = myHeader.frame.size.height;
    CGRect detailFrame  = CGRectMake(15, 0, width, height);
    CGFloat detailTextSize = detailFrame.size.height/1.5;
    // detail label
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:detailFrame];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:detailTextSize];
    detailLabel.textColor = [UIColor darkGrayColor];
    detailLabel.text = @"default";
    //   [label setAdjustsFontSizeToFitWidth:YES];
    [myHeader addSubview:detailLabel];
    NSString *title;
    if (section==0) {
        title = @"";
    }
    else
    {
        if (referenceArray.count!=0) {
            title = @"历史参考值";
        }
        else
            title = @"";
    }
    detailLabel.text = title;
    //    detailLabel.text = @"";
    return myHeader;
}
- (void)controlBtnClicked:(UIButton *)sender
{
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    if (sender.tag == 1) {
        [[BatteryManager shareManager] readReferenceValue:batteryGroup];
        [mbHud showWithTitle:@"读取参考值" detail:nil];
        [mbHud hide:YES afterDelay:1];
    }
    else{
        [[BatteryManager shareManager] updateReferenceValue:batteryGroup];
        [mbHud showWithTitle:@"设置参考值" detail:nil];
        [mbHud hide:YES afterDelay:1];
    }
}
- (void)managerDidReceiveReferenceValue:(NSDictionary *)dic
{
    if (referenceArray.count >= HIS_COUNT) {
        [referenceArray removeObjectAtIndex:0];
        [referenceArray addObject:dic];
    }
    else
    {
        [referenceArray addObject:dic];
    }
    [self.tableView reloadData];
}
@end
