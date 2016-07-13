//
//  SettingViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "SettingViewController.h"
#import "Define.h"
@interface SettingViewController ()<BatteryManagerDelegate>
- (IBAction)edit:(UIBarButtonItem *)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    NSString *setting = NSLocalizedString(@"setting", nil);
    self.title = setting;
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        //取出对象
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Battery *battery = appDelegate.battery;
        [[BatteryManager shareManager] readParaOfBattery:battery];
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
    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Battery *battery = appDelegate.battery;
    [[BatteryManager shareManager] readParaOfBattery:battery];
    [[BatteryManager shareManager] setDelegate:self];
    //更新界面
    [self.tableView reloadData];
}
#pragma mark -  BatteryManagerDelegate
-(void)managerDidReceiveData
{
    //更新界面
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80+32, 30)];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.textAlignment = NSTextAlignmentCenter;
        [textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
        textField.tag = 1;
        [view addSubview:textField];
        textField.enabled = NO;
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 0, 30, 30)];
        unitLabel.textAlignment = NSTextAlignmentLeft;
        unitLabel.tag = 2;
        [view addSubview:unitLabel];
        cell.accessoryView = view;
    }

    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Battery *battery = appDelegate.battery;
    
    
    NSString *nominalCapacity = NSLocalizedString(@"nominalCapacity", nil);
    NSString *nominalOutputVoltage = NSLocalizedString(@"nominalOutputVoltage", nil);
    NSString *cutoffVoltage = NSLocalizedString(@"cutoffVoltage", nil);
    NSString *maximumDischargeCurrent = NSLocalizedString(@"maximumDischargeCurrent", nil);

    
    NSArray *array = @[@[nominalCapacity,@"nominalCapacity",@"AH",@"elecIcon"],
                       @[nominalOutputVoltage,@"singleVoltage",@"V",@"voltageIcon"],
                       @[cutoffVoltage,@"cutoffVoltage",@"V",@"voltageIcon"],
                       @[maximumDischargeCurrent,@"dischargeCurrentPara",@"A",@"currentIcon"]
                       ];
    cell.textLabel.text = [array[indexPath.row] firstObject];
//    cell.textLabel.font = [UIFont systemFontOfSize:10];
    NSString *valueName = [array[indexPath.row] objectAtIndex:1];
    NSString *value = [[battery valueForKey:valueName] description];
    NSString *unit = [array[indexPath.row] objectAtIndex:2];
    UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
    textField.text = value;
    NSString *iconName = [array[indexPath.row] objectAtIndex:3];
    cell.imageView.image = [UIImage imageNamed:iconName];
    UILabel *unitLabel = (UILabel *)[cell.accessoryView viewWithTag:2];
    unitLabel.text = unit;
    switch (indexPath.row) {
        case 0:
            textField.text = @"100";
            break;
        case 1:
            textField.text = @"12";
            break;
        case 2:
            textField.text = @"10.8";
            break;
        case 3:
            textField.text = @"10";
            break;
        default:
            break;
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
    
    NSString *title = NSLocalizedString(@"electricityParameters", nil);
    detailLabel.text = title;
    
    return myHeader;
}
- (void)textFieldValueChanged:(UITextField *)sender
{
    
}
#pragma mark -  Action
- (IBAction)edit:(UIBarButtonItem *)sender {
    NSString *cancelString = NSLocalizedString(@"Cancel", nil);
    NSString *saveString = NSLocalizedString(@"Save", nil);
    NSString *editString = NSLocalizedString(@"Edit", nil);
    
    NSString *title = [sender.title isEqual:editString]?saveString:editString;
    sender.title = title;
     if ([sender.title isEqual:saveString]) {
         self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:cancelString style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
     }
    for (int i=0; i<4; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
        textField.enabled = !textField.enabled;
    }
    //保存进行判断
    if ([sender.title isEqual:editString]) {
        self.navigationItem.leftBarButtonItem = nil;
        //设定参数
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Battery *battery = appDelegate.battery;
        NSMutableArray *valueArray = [NSMutableArray array];
        //取出4个参数值
        for (int i = 0; i<4; i++) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *numTemp = [numberFormatter numberFromString:textField.text];
            if (numTemp == nil) {
                return;
            }
            [valueArray addObject:numTemp];
        }
        
        [[BatteryManager shareManager] setParaOfBattery:battery nominalCapacity:valueArray[0] singleVoltage:valueArray[1] cutoffVoltage:valueArray[2] dischargeCurrentPara:valueArray[3]];

    }


   
}
- (void)cancel:(UIBarButtonItem *)sender {
    NSString *editString = NSLocalizedString(@"Edit", nil);
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.title = editString;
    for (int i=0; i<4; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
        textField.enabled = !textField.enabled;
    }

}
@end
