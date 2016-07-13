//
//  DischargeViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "DischargeViewController.h"
#import "AppDelegate.h"
@interface DischargeViewController ()<BatteryManagerDelegate>

@end

@implementation DischargeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    NSString *discharge = NSLocalizedString(@"discharge", nil);
    self.title = discharge;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BatteryManager shareManager] setDelegate:self];
    //更新界面
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -  BatteryManagerDelegate
-(void)managerDidReceiveData
{
    //更新界面
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0?1:4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    if (indexPath.section == 0) {
        NSString *dischargeOperation = NSLocalizedString(@"dischargeOperation", nil);
        cell.textLabel.text = dischargeOperation;
        cell.imageView.image = [UIImage imageNamed:@"dischargeBig"];
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
            NSString *start = NSLocalizedString(@"start", nil);
            NSString *stop = NSLocalizedString(@"stop", nil);
            [btn setTitle:i==0?start:stop forState:UIControlStateNormal];
            
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            //                btn.titleLabel.textColor = [UIColor blackColor];
            btn.tag = i+1;
            [btn addTarget:self action:@selector(controlBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
        }

    }
    else
    {
        //取出对象
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Battery *battery = appDelegate.battery;
        
        NSString *dischargeOutputVoltage = NSLocalizedString(@"dischargeOutputVoltage", nil);
        NSString *dischargeOutputCurrent = NSLocalizedString(@"dischargeOutputCurrent", nil);
        NSString *batteryDischargeCapacity = NSLocalizedString(@"batteryDischargeCapacity", nil);
        NSString *actualDischargePeriod = NSLocalizedString(@"actualDischargePeriod", nil);
        
        NSArray *array = @[@[dischargeOutputVoltage,@"dischargeVoltage",@"Vdc",@"voltageIcon"],
                           @[dischargeOutputCurrent,@"dischargeCurrent",@"Adc",@"currentIcon"],
                           @[batteryDischargeCapacity,@"dischargeCapacity",@"AH",@"elecIcon"],
                           @[actualDischargePeriod,@"",@"",@"time"]
                        ];
        cell.textLabel.text = [array[indexPath.row] firstObject];
        
        if (indexPath.row != 3) {
            NSString *valueName = [array[indexPath.row] objectAtIndex:1];
            NSString *value = [[battery valueForKey:valueName] description];
            NSString *unit = [array[indexPath.row] objectAtIndex:2];
            cell.detailTextLabel.text =[value stringByAppendingString:unit];
            NSString *iconName = [array[indexPath.row] objectAtIndex:3];
            cell.imageView.image = [UIImage imageNamed:iconName];

        }
        else
        {
            NSString *hour = [battery valueForKey:@"hour"];
            NSString *minute = [battery valueForKey:@"minute"];
            NSString *second = [battery valueForKey:@"second"];
            NSString *time = [NSString stringWithFormat:@"%@时%@分%@秒",hour,minute,second];
            if (hour == nil) {
                time = nil;
            }
            cell.detailTextLabel.text = time;
            NSString *iconName = [array[indexPath.row] objectAtIndex:3];
            cell.imageView.image = [UIImage imageNamed:iconName];
        }
        
    }
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
    
    NSString *title = section==0?NSLocalizedString(@"userControl", nil):NSLocalizedString(@"electricityParameters", nil);
    detailLabel.text = title;
    
    return myHeader;
}

#pragma mark -  Action
- (void)controlBtnClicked:(UIButton *)sender
{
    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Battery *battery = appDelegate.battery;
    if (sender.tag == 1) { //开始
        [[BatteryManager shareManager] startDischargeOfBattery:battery];
    }
    else{
        [[BatteryManager shareManager] stopDischargeOfBattery:battery];
    }

}
@end
