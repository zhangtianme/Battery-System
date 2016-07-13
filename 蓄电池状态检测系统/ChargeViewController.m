//
//  ChargeViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "ChargeViewController.h"
#import "Define.h"
@interface ChargeViewController ()<BatteryManagerDelegate>

@end

@implementation ChargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    NSString *charge = NSLocalizedString(@"charge", nil);
    self.title = charge;
//    [self.tableView addHeaderWithCallback:^{
//        //取出对象
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        Battery *battery = appDelegate.battery;
//        [[BatteryManager shareManager] readPredictedDataOfBattery:battery];
//        //加HUD
//        [MBProgressHUD showMessage:nil];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView headerEndRefreshing];
//            [MBProgressHUD hideHUD];
//        });
//    }];

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
    return section==0?1:8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    if (indexPath.section == 0) {
        NSString *chargeOperation = NSLocalizedString(@"chargeOperation", nil);
        cell.textLabel.text = chargeOperation;
        cell.imageView.image = [UIImage imageNamed:@"chargeBig"];
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
        
        NSString *chargePowerVoltage = NSLocalizedString(@"chargePowerVoltage", nil);
        NSString *chargeAlternatingCurrent = NSLocalizedString(@"chargeAlternatingCurrent", nil);
        NSString *chargeInputPower = NSLocalizedString(@"chargeInputPower", nil);
        NSString *sourcePowerFactor = NSLocalizedString(@"sourcePowerFactor", nil);
        NSString *chargePowerConsumption = NSLocalizedString(@"chargePowerConsumption", nil);
        NSString *chargeBatterySideVoltage = NSLocalizedString(@"chargeBatterySideVoltage", nil);
        NSString *chargeBatterySideCurrent = NSLocalizedString(@"chargeBatterySideCurrent", nil);
        NSString *chargeBatteryLevel = NSLocalizedString(@"chargeBatteryLevel", nil);
        
        NSArray *array = @[@[chargePowerVoltage,@"acVoltage",@"Vac",@"voltageIcon"],
                           @[chargeAlternatingCurrent,@"acCurrent",@"Aac",@"currentIcon"],
                           @[chargeInputPower,@"power",@"kW",@"powerIcon"],
                           @[sourcePowerFactor,@"powerFactor",@"",@"powerRateIcon"],
                           @[chargePowerConsumption,@"powerConsumption",@"kWh",@"elecIcon"],
                           @[chargeBatterySideVoltage,@"chargeVoltage",@"Vdc",@"voltageIcon"],
                           @[chargeBatterySideCurrent,@"chargeCurrent",@"Adc",@"currentIcon"],
                           @[chargeBatteryLevel,@"chargeEnergy",@"AH",@"elecIcon"]
                           ];
        cell.textLabel.text = [array[indexPath.row] firstObject];
        NSString *valueName = [array[indexPath.row] objectAtIndex:1];
        NSString *value = [[battery valueForKey:valueName] description];
        NSString *unit = [array[indexPath.row] objectAtIndex:2];
        cell.detailTextLabel.text =[value stringByAppendingString:unit];
        NSString *iconName = [array[indexPath.row] objectAtIndex:3];
        cell.imageView.image = [UIImage imageNamed:iconName];
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
        [[BatteryManager shareManager] startChargeOfBattery:battery];
    }
    else{
        [[BatteryManager shareManager] stopChargeOfBattery:battery];
    }
}
@end
