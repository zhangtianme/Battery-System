//
//  PredictViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "PredictViewController.h"
#import "Define.h"
@interface PredictViewController ()<BatteryManagerDelegate>

@end

@implementation PredictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    NSString *prediction = NSLocalizedString(@"prediction", nil);
    self.title = prediction;
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
//        Byte data[]={0xAA,01,02,0x10,0x2D,0x69,02,0x58,0x61,00,0xF2,00,64,00,0x9F,00,0x0F,0xA4,0xBC};
//        NSData *receiveData = [NSData dataWithBytes:data length:20];
        //取出对象
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Battery *battery = appDelegate.battery;
//        [[BatteryManager shareManager] socket:battery.socket didReadData:receiveData withTag:10];
        
        [[BatteryManager shareManager] readPredictedDataOfBattery:battery];
        //加HUD
        [MBProgressHUD showMessage:nil];
   
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView headerEndRefreshing];
            [MBProgressHUD hideHUD];
        });
    }];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BatteryManager shareManager] setDelegate:self];
    //更新界面
    [self.tableView reloadData];
    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Battery *battery = appDelegate.battery;
    [[BatteryManager shareManager] readPredictedDataOfBattery:battery];
}
#pragma mark -  BatteryManagerDelegate
-(void)managerDidReceiveData
{
    //更新界面
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Battery *battery = appDelegate.battery;
    NSString *batteryVoltage = NSLocalizedString(@"batteryVoltage", nil);
    NSString *dischargeCurrent = NSLocalizedString(@"dischargeCurrent", nil);
    NSString *internalResistance = NSLocalizedString(@"internalResistance", nil);
    NSString *peakPointCurrent = NSLocalizedString(@"peakPointCurrent", nil);
    NSString *healthDegree = NSLocalizedString(@"healthDegree", nil);
    NSString *batteryCapacity = NSLocalizedString(@"batteryCapacity", nil);
    NSString *batteryLevel = NSLocalizedString(@"batteryLevel", nil);

    
    NSArray *array = @[@[batteryVoltage,@"voltage",@"V",@"voltageIcon"],
                       @[dischargeCurrent,@"current",@"A",@"currentIcon"],
                       @[internalResistance,@"internalRes",@"mΩ",@"res"],
                       @[peakPointCurrent,@"maxCurrent",@"A",@"currentIcon"],
                       @[healthDegree,@"healthState",@"%",@"health"],
                       @[batteryCapacity,@"capacity",@"AH",@"elecIcon"],
                       @[batteryLevel,@"currentEnergy",@"%",@"elecIcon"]
                       ];
    cell.textLabel.text = [array[indexPath.row] firstObject];
    NSString *valueName = [array[indexPath.row] objectAtIndex:1];
    NSString *value = [[battery valueForKey:valueName] description];
    NSString *unit = [array[indexPath.row] objectAtIndex:2];
    cell.detailTextLabel.text =[value stringByAppendingString:unit];
    NSString *iconName = [array[indexPath.row] objectAtIndex:3];
    cell.imageView.image = [UIImage imageNamed:iconName];
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
    
    NSString *title = NSLocalizedString(@"electricityParameters", nil);
    detailLabel.text = title;

    return myHeader;
}


@end
