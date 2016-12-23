//
//  ChargeViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "ChargeViewController.h"
#import "Define.h"
@interface ChargeViewController ()<BatteryManagerDelegate,MemDataDelegate>
{
    MBProgressHUD *mbHud;
}
@end

@implementation ChargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];

    if (!mbHud) {
        mbHud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:mbHud];
        mbHud.dimBackground = YES;
    }

    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        //        Byte data[]={0xAA,01,02,0x10,0x2D,0x69,02,0x58,0x61,00,0xF2,00,64,00,0x9F,00,0x0F,0xA4,0xBC};
        //        NSData *receiveData = [NSData dataWithBytes:data length:20];
        //取出对象
        BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
        //        [[BatteryManager shareManager] socket:battery.socket didReadData:receiveData withTag:10];
        if ([MemDataManager shareManager].isIntranet) {
            [[BatteryManager shareManager] readPredictedDataOfBattery:batteryGroup];
        }
        else
        {
            [[MemDataManager shareManager] updataRealData];
            //       NSDictionary *dic = [BatteryService inquiryPackRealDataWithAddr:@"1"];
            //        NSLog(@"%@",dic);
        }
        

        //加HUD
        [MBProgressHUD showMessage:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView headerEndRefreshing];
            [MBProgressHUD hideHUD];
        });
    }];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBattery) name:@"ChangeBattery" object:nil];
}
- (void)changeBattery
{
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [MemDataManager shareManager].delegate = self;
//    NSString *charge = NSLocalizedString(@"charge", nil);
//    self.tabBarController.title = charge;
    [[BatteryManager shareManager] setDelegate:self];
     [MemDataManager shareManager].delegate = self;
    //更新界面
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    });
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}
- (void)refresh
{
    //取出对象
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    //        [[BatteryManager shareManager] socket:battery.socket didReadData:receiveData withTag:10];
    if ([MemDataManager shareManager].isIntranet) {
        [[BatteryManager shareManager] readPredictedDataOfBattery:batteryGroup];
    }
    else
    {
        [[MemDataManager shareManager] updataRealData];
        //       NSDictionary *dic = [BatteryService inquiryPackRealDataWithAddr:@"1"];
        //        NSLog(@"%@",dic);
    }
    

    //加HUD
    [MBProgressHUD showMessage:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });

    
}

#pragma mark -  BatteryManagerDelegate
- (void)serviceDidReceiveData
{
    //更新界面
    [self.tableView reloadData];
}
-(void)managerDidReceiveData
{
    //更新界面
     [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section>=1) {
        return 5;
    }
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }
        //取出对象
        BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
        
        NSString *chargePowerVoltage = NSLocalizedString(@"chargePowerVoltage", nil);
        NSString *chargeAlternatingCurrent = NSLocalizedString(@"chargeAlternatingCurrent", nil);
        NSString *chargeInputPower = NSLocalizedString(@"chargeInputPower", nil);
        NSString *sourcePowerFactor = NSLocalizedString(@"sourcePowerFactor", nil);
        NSString *chargePowerConsumption = NSLocalizedString(@"chargePowerConsumption", nil);
        NSString *chargeBatterySideVoltage = NSLocalizedString(@"chargeBatterySideVoltage", nil);
        NSString *chargeBatterySideCurrent = NSLocalizedString(@"chargeBatterySideCurrent", nil);
        NSString *state = @"电池组状态";
        
        NSArray *array = @[@[chargePowerVoltage,@"acVoltage",@"Vac",@"voltageIcon"],
                           @[chargeAlternatingCurrent,@"acCurrent",@"Aac",@"currentIcon"],
                           @[chargeInputPower,@"power",@"W",@"powerIcon"],
                           @[sourcePowerFactor,@"powerFactor",@"",@"powerRateIcon"],
                           @[chargePowerConsumption,@"powerConsumption",@"kWh",@"elecIcon"],
                           @[chargeBatterySideVoltage,@"chargeVoltage",@"Vdc",@"voltageIcon"],
                           @[chargeBatterySideCurrent,@"chargeCurrent",@"Adc",@"currentIcon"],
                           @[state,@"state",@"",@"elecIcon"]
                           ];
        cell.textLabel.text = [array[indexPath.row] firstObject];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        NSString *valueName = [array[indexPath.row] objectAtIndex:1];
        NSString *value;
        if (indexPath.row == 7) {
            value = [[batteryGroup valueForKey:valueName] boolValue]==YES?@"放电":@"维护";
        }
        else
            value = [[batteryGroup valueForKey:valueName] description];
        
        if (value == nil) {
            cell.detailTextLabel.text = @"--";
        }
        else
        {
            NSString *unit = [array[indexPath.row] objectAtIndex:2];
            cell.detailTextLabel.text =[value stringByAppendingString:unit];
        }
        NSString *iconName = [array[indexPath.row] objectAtIndex:3];
        cell.imageView.image = [UIImage imageNamed:iconName];
        return cell;

    }
    else if (indexPath.section >=1 &&indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"operationCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"operationCell"];
        }
        NSString *chargeOperation = NSLocalizedString(@"chargeOperation", nil);
        cell.textLabel.text = chargeOperation;
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
            NSString *start = NSLocalizedString(@"start", nil);
            NSString *stop = NSLocalizedString(@"stop", nil);
            
            [btn setTitle:i==0?start:stop forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            //                btn.titleLabel.textColor = [UIColor blackColor];
            btn.tag = i+1;
            [btn addTarget:self action:@selector(controlBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
        }
        return cell;
    }
    else if(indexPath.section>=1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }
        //取出对象
        BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
        
        
        NSString *chargePowerVoltage = @"电压";
        NSString *chargeAlternatingCurrent = @"电流";
        NSString *chargeInputPower = @"充入容量";
        NSString *state = @"状态";
        
        NSArray *array = @[@[chargePowerVoltage,@"chargeVoltage",@"Vac",@"voltageIcon"],
                           @[chargeAlternatingCurrent,@"chargeCurrent",@"Aac",@"currentIcon"],
                           @[chargeInputPower,@"chargeEnergy",@"AH",@"powerIcon"],
                           @[state,@"state",@"",@"elecIcon"]
                           ];
//         cell.textLabel.text = @"哈哈哈哈";
        NSUInteger index = indexPath.row-1;
        if (index>=4) {
            NSLog(@"index---%lu",(unsigned long)index);
        }
        
        cell.textLabel.text = [array[index] firstObject];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        
        NSString *valueName = [array[index] objectAtIndex:1];
        
        NSString *value;
        if (index == 3) {
            value = [batteryGroup.batterys[indexPath.section-1] state]==YES?@"开始":@"停止";
        }
        else
            value = [[batteryGroup.batterys[indexPath.section-1] valueForKey:valueName] description];

        if (value == nil) {
            cell.detailTextLabel.text = @"--";
        }
        else
        {
            NSString *unit = [array[index] objectAtIndex:2];
            cell.detailTextLabel.text =[value stringByAppendingString:unit];
        }

        NSString *iconName = [array[index] objectAtIndex:3];
        cell.imageView.image = [UIImage imageNamed:iconName];
    }
    return cell;
    
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *myHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
//    myHeader.backgroundColor = matchColor; // 淡蓝色背景色
//    
//    CGFloat width = myHeader.frame.size.width;
//    CGFloat height = myHeader.frame.size.height;
//    CGRect detailFrame  = CGRectMake(15, 0, width, height);
//    CGFloat detailTextSize = detailFrame.size.height/1.5;
//    // detail label
//    UILabel *detailLabel = [[UILabel alloc] initWithFrame:detailFrame];
//    detailLabel.textAlignment = NSTextAlignmentLeft;
//    detailLabel.font = [UIFont systemFontOfSize:detailTextSize];
//    detailLabel.textColor = [UIColor darkGrayColor];
//    detailLabel.text = @"default";
//    //   [label setAdjustsFontSizeToFitWidth:YES];
//    [myHeader addSubview:detailLabel];
//    
//    NSString *title = section==0?NSLocalizedString(@"userControl", nil):NSLocalizedString(@"electricityParameters", nil);
//    detailLabel.text = title;
//    
//    return myHeader;
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = @[@"电源检测",@"电池#1",@"电池#2",@"电池#3",@"电池#4"];
    return array[section];
}
#pragma mark -  Action
- (void)controlBtnClicked:(UIButton *)sender
{
    //取出对象
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSUInteger index = [[self.tableView indexPathForCell:cell] section]-1;
    
    if (sender.tag == 1) { //开始
        if ([MemDataManager shareManager].isIntranet) {
            [[BatteryManager shareManager] chargeBattery:batteryGroup number:index start:YES];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [BatteryService insertChargeOrderAddr:batteryGroup.address number:index isStart:YES];
            });

           
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [[MemDataManager shareManager] updataRealData];
            });
        }

        [mbHud showWithTitle:@"开始充电" detail:nil];
        [mbHud hide:YES afterDelay:1];
    }
    else{
       
        if ([MemDataManager shareManager].isIntranet) {
            [[BatteryManager shareManager] chargeBattery:batteryGroup number:index start:NO];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                  [BatteryService insertChargeOrderAddr:batteryGroup.address number:index isStart:NO];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[MemDataManager shareManager] updataRealData];
            });
        }
        [mbHud showWithTitle:@"停止充电" detail:nil];
        [mbHud hide:YES afterDelay:1];
    }
}
@end
