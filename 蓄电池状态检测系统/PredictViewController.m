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
#import "HisDataViewController.h"
@interface PredictViewController ()<BatteryManagerDelegate,MemDataDelegate>
{
    NSUInteger showIndex; //之前准备按参数、按电池两种方式显示的，后来放弃治疗了
    NSDictionary *paramDic;
}
@end

@implementation PredictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.allowsSelection = NO;
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
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBattery) name:@"GetSites" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBattery) name:@"NetMode" object:nil];

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
      if (![MemDataManager shareManager].isIntranet)
      {
        if (indexPath.row == 6) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
      }
        else
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row != 6&& [MemDataManager shareManager].isIntranet != YES) //历史数据
    {
        
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
        NSArray *nameArray = @[@"Fore_U",@"Fore_R",@"Fore_I",@"Fore_Health",@"Fore_Capacity",@"Fore_Electricity"];
        NSUInteger number = indexPath.section+1;
     
        paramDic = @{@"BID":[MemDataManager shareManager].currentGroup.bid,
                     @"Number":[NSString stringWithFormat:@"%lu",(unsigned long)number],
                     @"Para":nameArray[indexPath.row],
                     @"name":[array[indexPath.row] firstObject],
                     @"Unit":array[indexPath.row][2],
                     @"isPack":@"0"
                     };
         [self performSegueWithIdentifier:@"Fore" sender:nil];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HisDataViewController *hisVC = segue.destinationViewController;
    hisVC.paramDic = paramDic;
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
