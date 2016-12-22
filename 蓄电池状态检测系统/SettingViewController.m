//
//  SettingViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "SettingViewController.h"
#import "Define.h"
#import "ZXPPickerView.h"
@interface SettingViewController ()<BatteryManagerDelegate,ZXPPickerViewDelegate,MemDataDelegate>
{
    BOOL isEdit;
    BOOL isMaintain;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
    self.tableView.tableFooterView = [[UIView alloc] init];

    
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
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
//    NSString *setting = NSLocalizedString(@"setting", nil);
//    self.tabBarController.title = setting;
    //取出对象
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    [[BatteryManager shareManager] readParaOfBattery:batteryGroup];
    [[BatteryManager shareManager] setDelegate:self];
      [MemDataManager shareManager].delegate = self;
    //更新界面
    [self.tableView reloadData];
}
#pragma mark -  BatteryManagerDelegate
-(void)managerDidReceiveData
{
    //更新界面
    [self.tableView reloadData];
}
- (void)serviceDidReceiveData
{
    //更新界面
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section==2) {
//        return 1;
//    }
//    return 6;
    return section==0?6:1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    if (indexPath.section==1) {
        
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        UIButton *btnCenter = [UIButton buttonWithType:UIButtonTypeSystem];
        btnCenter.tintColor = themeColor;
        [btnCenter setTitle:@"编辑" forState:UIControlStateNormal];
        btnCenter.size = CGSizeMake(60, 40);
        btnCenter.center = CGPointMake(self.view.width/2, cell.contentView.height/2);
        [cell.contentView addSubview:btnCenter];
        [btnCenter addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
        btnCenter.tag = 1;
        
        UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeSystem];
        btnLeft.tintColor = themeColor;
        [btnLeft setTitle:@"取消" forState:UIControlStateNormal];
        btnLeft.size = CGSizeMake(60, 40);
        btnLeft.center = CGPointMake(40, cell.contentView.height/2);
        [cell.contentView addSubview:btnLeft];
        [btnLeft addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        btnLeft.tag = 2;
        
        UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeSystem];
        btnRight.tintColor = themeColor;
        [btnRight setTitle:@"确定" forState:UIControlStateNormal];
        btnRight.size = CGSizeMake(60, 40);
        btnRight.center = CGPointMake(self.view.width-40, cell.contentView.height/2);
        [cell.contentView addSubview:btnRight];
        [btnRight addTarget:self action:@selector(ensure) forControlEvents:UIControlEventTouchUpInside];
        btnRight.tag = 3;
        if (isEdit == NO) {
            btnRight.hidden = YES;
            btnLeft.hidden = YES;
            btnCenter.hidden = NO;
        }
        else {
            btnRight.hidden = NO;
            btnLeft.hidden = NO;
            btnCenter.hidden = YES;
        }

            
        
        return cell;
    }
    
    
    
//    if (indexPath.section==0) {
//        cell.imageView.image = [UIImage imageNamed:@"reference"];
//        cell.textLabel.text = @"参考值";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        return cell;
//    }
    
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row<3) {
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
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    
    NSString *nominalCapacity = NSLocalizedString(@"nominalCapacity", nil);
    NSString *nominalOutputVoltage = NSLocalizedString(@"nominalOutputVoltage", nil);
    NSString *cutoffVoltage = NSLocalizedString(@"cutoffVoltage", nil);
    NSString *batteryNumber = @"当前电池序号";
    NSString *workState = @"工作状态";
    NSString *isMaintainString = @"维护";
//    NSString *maximumDischargeCurrent = NSLocalizedString(@"maximumDischargeCurrent", nil);

    
    NSArray *array = @[
                       
                       @[nominalCapacity,@"nominalCapacity",@"AH",@"elecIcon"],
                       @[nominalOutputVoltage,@"singleVoltage",@"V",@"voltageIcon"],
                       @[cutoffVoltage,@"cutoffVoltage",@"V",@"voltageIcon"],
                       @[batteryNumber,@"batteryNumber",@"",@"elecIcon"],
                       @[workState,@"workState",@"",@"elecIcon"],
                       @[isMaintainString,@"isMaintain",@"",@"elecIcon"],
//                       @[maximumDischargeCurrent,@"dischargeCurrentPara",@"A",@"currentIcon"]
                       ];
    cell.textLabel.text = [array[indexPath.row] firstObject];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
//    cell.textLabel.font = [UIFont systemFontOfSize:10];
    NSString *valueName = [array[indexPath.row] objectAtIndex:1];
    NSString *value = [[batteryGroup valueForKey:valueName] description];
    NSString *unit = [array[indexPath.row] objectAtIndex:2];
    
    NSString *iconName = [array[indexPath.row] objectAtIndex:3];
    cell.imageView.image = [UIImage imageNamed:iconName];
    if (indexPath.row<3) {
        UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
        textField.text = value;
        UILabel *unitLabel = (UILabel *)[cell.accessoryView viewWithTag:2];
        unitLabel.text = unit;
    }
    if (indexPath.row>=3) {
        NSString *stateName;
        if (indexPath.row == 4) {
            switch (value.intValue) {
                case 0:
                    stateName = @"等待";
                    break;
                case 1:
                    stateName = @"预测";
                    break;
                case 2:
                    stateName = @"放电";
                    break;
                case 3:
                    stateName = @"充电";
                    break;
                case 4:
                    stateName = @"校准";
                    break;
                default:
                    break;
            }
        }
        if (indexPath.row == 5) {
//            isMaintain = value.boolValue;
            stateName = value.intValue== 0?@"不自动维护":@"自动维护";
//            cell.detailTextLabel.textColor = themeColor;
//            cell.detailTextLabel.userInteractionEnabled = YES;
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//            [cell.detailTextLabel addGestureRecognizer:tap];
        }
        if (indexPath.row == 3) {
            cell.detailTextLabel.text = value.intValue==0?@"无":[@"#" stringByAppendingString:value];
        }
            else
              cell.detailTextLabel.text = stateName;
        
    }
    
//    switch (indexPath.row) {
//        case 0:
//            textField.text = @"100";
//            break;
//        case 1:
//            textField.text = @"12";
//            break;
//        case 2:
//            textField.text = @"10.8";
//            break;
//        case 3:
//            textField.text = @"10";
//            break;
//        default:
//            break;
//    }
     cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}
//- (void)tap
//{
//    NSLog(@"tap");
//    //picker
//    ZXPPickerView *picker = [ZXPPickerView new];
//    picker.dataSource = @[@"不自动维护",@"自动维护"];
//    picker.delegate = self;
//    [picker show];
//    [picker selectedRow:isMaintain section:0 animation:NO];
//}
- (void)zxp_pickerView:(ZXPPickerView *)pickerView didSelectRow:(NSInteger)row section:(NSInteger)section
{
    isMaintain = row;
    [self.tableView reloadData];
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
    
    //    NSString *title = section==0?@"":NSLocalizedString(@"electricityParameters", nil);
    //    detailLabel.text = title;
    detailLabel.text = @"";
    return myHeader;
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    if (indexPath.section == 0) {
////        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
////                                                                 bundle: nil];
////        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"Reference"];
////        [self.navigationController pushViewController:vc animated:YES];
////    }
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//}

- (void)textFieldValueChanged:(UITextField *)sender
{
    
}
#pragma mark -  Action
- (void)edit {
    isEdit = !isEdit;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    for (int i=0; i<3; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
        textField.enabled = !textField.enabled;
    }
}
- (void)ensure
{
    isEdit = !isEdit;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    for (int i=0; i<3; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
        textField.enabled = !textField.enabled;
    }
    //设定参数
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    NSMutableArray *valueArray = [NSMutableArray array];
    //取出4个参数值
    for (int i = 0; i<3; i++) {
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
    
    [[BatteryManager shareManager] setParaOfBattery:batteryGroup batteryNumber:@2 nominalCapacity:valueArray[0] singleVoltage:valueArray[1] cutoffVoltage:valueArray[2] isMaintain:@0];
    
//    [[BatteryManager shareManager] setParaOfBattery:batteryGroup nominalCapacity:valueArray[0] singleVoltage:valueArray[1] cutoffVoltage:valueArray[2] dischargeCurrentPara:valueArray[3]];

}
- (void)cancel {
    isEdit = !isEdit;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    for (int i=0; i<3; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell.accessoryView viewWithTag:1];
        textField.enabled = !textField.enabled;
    }

}
@end
