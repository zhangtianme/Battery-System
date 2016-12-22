//
//  PredictViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "PredictViewController.h"
#import "Define.h"
#import "BatteryService.h"
#import "MemDataManager.h"
@interface PredictViewController ()<BatteryManagerDelegate,MemDataDelegate>
{
    NSUInteger showIndex;
}
@end

@implementation PredictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
//    NSString *prediction = NSLocalizedString(@"prediction", nil);
    
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
        }
        //加HUD
        [MBProgressHUD showMessage:nil];
   
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView headerEndRefreshing];
            [MBProgressHUD hideHUD];
        });
    }];
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
//     self.tabBarController.title = @"电池状态预测";
    [[BatteryManager shareManager] setDelegate:self];
    [MemDataManager shareManager].delegate = self;
    //更新界面
    [self.tableView reloadData];
    
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return showIndex==0?4:6;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return showIndex==0?7:4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    if (showIndex == 0) {
        
        BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
        NSString *batteryVoltage = NSLocalizedString(@"batteryVoltage", nil);
        NSString *internalResistance = NSLocalizedString(@"internalResistance", nil);
        NSString *peakPointCurrent = NSLocalizedString(@"peakPointCurrent", nil);
        NSString *healthDegree = NSLocalizedString(@"healthDegree", nil);
        NSString *batteryCapacity = NSLocalizedString(@"batteryCapacity", nil);
        NSString *batteryLevel = NSLocalizedString(@"batteryLevel", nil);
        
        
        NSArray *array = @[@[batteryVoltage,@"voltage",@"V",@"voltageIcon"],
                           @[internalResistance,@"internalRes",@"mΩ",@"res"],
                           @[peakPointCurrent,@"maxCurrent",@"A",@"currentIcon"],
                           @[healthDegree,@"healthState",@"%",@"health"],
                           @[batteryLevel,@"currentEnergy",@"%",@"elecIcon"],
                           @[batteryCapacity,@"capacity",@"AH",@"elecIcon"],
                           @[@"获取时间",@"getTimeFore",@"",@"time"]
                           ];
        cell.textLabel.text = [array[indexPath.row] firstObject];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        NSString *valueName = [array[indexPath.row] objectAtIndex:1];
        NSString *value = [[batteryGroup.batterys[indexPath.section] valueForKey:valueName] description];
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
    return cell;
}
//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSString *batteryVoltage = NSLocalizedString(@"batteryVoltage", nil);
//    NSString *internalResistance = NSLocalizedString(@"internalResistance", nil);
//    NSString *peakPointCurrent = NSLocalizedString(@"peakPointCurrent", nil);
//    NSString *healthDegree = NSLocalizedString(@"healthDegree", nil);
//    NSString *batteryCapacity = NSLocalizedString(@"batteryCapacity", nil);
//    NSString *batteryLevel = NSLocalizedString(@"batteryLevel", nil);
//    if (showIndex == 0) {
//        return @[@"电池#1",@"电池#2",@"电池#3",@"电池#4"];
//    }
//    else
//        return @[batteryVoltage,internalResistance,peakPointCurrent,healthDegree,batteryCapacity,batteryLevel];
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *batteryVoltage = NSLocalizedString(@"batteryVoltage", nil);
    NSString *internalResistance = NSLocalizedString(@"internalResistance", nil);
    NSString *peakPointCurrent = NSLocalizedString(@"peakPointCurrent", nil);
    NSString *healthDegree = NSLocalizedString(@"healthDegree", nil);
    NSString *batteryCapacity = NSLocalizedString(@"batteryCapacity", nil);
    NSString *batteryLevel = NSLocalizedString(@"batteryLevel", nil);
    NSArray *array;
    if (showIndex == 0) {
        array = @[@"电池#1",@"电池#2",@"电池#3",@"电池#4"];
    }
    else
        array = @[batteryVoltage,internalResistance,peakPointCurrent,healthDegree,batteryCapacity,batteryLevel];
    return array[section];
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *myHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
//    myHeader.backgroundColor = matchColor; // 淡蓝色背景色
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
//    NSString *title = NSLocalizedString(@"electricityParameters", nil);
//    detailLabel.text = title;
//
//    return myHeader;
//}


@end
