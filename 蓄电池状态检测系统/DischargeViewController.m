//
//  DischargeViewController.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/28.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "DischargeViewController.h"
#import "AppDelegate.h"
#import "DVLineChartView.h"
#import "TLTagsControl.h"
#import "UIView+Extension.h"
#define POINT_COUNT 30
@interface DischargeViewController ()<BatteryManagerDelegate,TLTagsControlDelegate,MemDataDelegate>
{
    MBProgressHUD *mbHud;
    NSMutableArray *dischargeArray;
    NSInteger currentYIndex;//选择的Y轴单位
    BOOL isLoad;
    UIView *hudView;
    NSInteger currentNumber;
    BOOL isDischargeSuccess;
}




@property (weak, nonatomic) IBOutlet UILabel *batteryNumber;
- (IBAction)clearChart:(id)sender;
@end

@implementation DischargeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    currentYIndex = 0;
    dischargeArray = [NSMutableArray array];
    
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = matchColor;
//    self.tableView.tableFooterView = [[UIView alloc] init];

    if (!mbHud) {
        mbHud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:mbHud];
        mbHud.dimBackground = YES;
    }
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{

        [[MemDataManager shareManager] updataRealData];
        
        //加HUD
        [MBProgressHUD showMessage:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView headerEndRefreshing];
            [MBProgressHUD hideHUD];
        });
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBattery) name:@"ChangeBattery" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBattery) name:@"GetSites" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNetMode) name:@"NetMode" object:nil];
}
- (void)changeNetMode
{
    if ([MemDataManager shareManager].isIntranet) {
        self.tableView.headerHidden = YES;
    }
    else
        self.tableView.headerHidden = NO;
    [self.tableView reloadData];
}
- (void)changeBattery
{
    [self.tableView reloadData];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)press:(UILongPressGestureRecognizer *)sender {
     if (sender.state == UIGestureRecognizerStateBegan)
     {
         NSLog(@"开始");
         //取出对象
         BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
         NSString *value = [batteryGroup.dischargeCurrent description];
//         NSString *string = [NSString stringWithFormat:@"放电电流：%@",value];
         NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"hud" owner:self options:nil];
         hudView = nibArray[0];
         hudView.centerX = self.view.width/2;
         hudView.centerY = self.view.height/2;
         hudView.layer.cornerRadius = 10;
         UILabel *titleLabel = [hudView viewWithTag:1];
         UILabel *detailLabel = [hudView viewWithTag:2];
         titleLabel.text = @"放电电流";
         detailLabel.text = value==nil?@"无数据":[value stringByAppendingString:@"Adc"];
         [[[UIApplication sharedApplication] keyWindow] addSubview:hudView];
//         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//         hud.labelText = string;
//         UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//         view.backgroundColor = [UIColor redColor];
//         hud.customView = view;
//         [mbHud showWithTitle:@"haha" detail:@"hehe"];
         
     }
    if (sender.state == UIGestureRecognizerStateEnded||sender.state == UIGestureRecognizerStateCancelled)
    {
        NSLog(@"结束");
        [hudView removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([MemDataManager shareManager].isIntranet) {
        self.tableView.headerHidden = YES;
    }
    else
    {
        self.tableView.headerHidden = NO;
        [self.tableView reloadData];
    }
//    NSString *discharge = NSLocalizedString(@"discharge", nil);
//    self.tabBarController.title = discharge;
    
    UILabel *extraInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    //    extraInfoLabel.backgroundColor = [UIColor blackColor];
    [extraInfoLabel setText:@"附加信息"];
    extraInfoLabel.textColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:extraInfoLabel];
    extraInfoLabel.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
    longPressRecognizer.minimumPressDuration = 0.1;
    [extraInfoLabel addGestureRecognizer:longPressRecognizer];
     });
    [[BatteryManager shareManager] setDelegate:self];
    [MemDataManager shareManager].delegate = self;
    //更新界面
    if ([MemDataManager shareManager].isIntranet) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationNone];
    }
    else
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:UITableViewRowAnimationNone];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}
#pragma mark -  BatteryManagerDelegate
//-(void)managerDidReceiveData
//{
//    //更新界面
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//}
- (void)serviceDidReceiveData
{
    if ([MemDataManager shareManager].isIntranet) {
        return;
    }
    isDischargeSuccess = YES;
    //更新界面
    [self.tableView reloadData];
}
- (void)managerDidReceiveDischargeValue:(NSDictionary *)dic
{
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    if (currentNumber==0) { //初次接收数据
        currentNumber = batteryGroup.batteryNumber.integerValue;
    }
    else if(currentNumber!=batteryGroup.batteryNumber.integerValue)//切换电池
    {
         currentNumber = batteryGroup.batteryNumber.integerValue;
         [dischargeArray removeAllObjects];
    }
    else
    {
        
    }
    
    if (dischargeArray.count >= POINT_COUNT) {
        [dischargeArray removeObjectAtIndex:0];
        [dischargeArray addObject:dic];
    }
    else
    {
        [dischargeArray addObject:dic];
    }
    //滚动到最下面
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //更新界面
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    if ([MemDataManager shareManager].isIntranet) {
//        return 3;
//    }
//    else
        return 3;


}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if ([MemDataManager shareManager].isIntranet) {
        if (section == 2) {
            return 1;
        }

    return section==0?4:3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"operationCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"operationCell"];
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
                btn.tag = i+1+indexPath.row*2;
                [btn addTarget:self action:@selector(controlBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"operation"];
        }
//        if (indexPath.row!=0)
//        {
//            NSString *dischargeOperation = NSLocalizedString(@"dischargeOperation", nil);
            cell.textLabel.text = [NSString stringWithFormat:@"放电-电池#%ld",(long)indexPath.row+1];
//        }
//        else
//        {
//            NSString *dischargeOperation = @"自动校准";
//            cell.textLabel.text = dischargeOperation;
//        }
    }
    else if(indexPath.section == 2)
    {
        if (![MemDataManager shareManager].isIntranet)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"normalCell"];
            }
            cell.textLabel.text = @"放电电池编号";
            cell.imageView.image = [UIImage imageNamed:@"编号.png"];
            
            if ([MemDataManager shareManager].currentGroup.batteryNumber.integerValue == 0 ||[MemDataManager shareManager].currentGroup.batteryNumber == nil) {
                cell.detailTextLabel.text = @"无";
            }
            else
                cell.detailTextLabel.text = [NSString stringWithFormat:@"#%@",[MemDataManager shareManager].currentGroup.batteryNumber];
            return cell;
        }
            
        cell = [tableView dequeueReusableCellWithIdentifier:@"chartCell"];
     
        DVLineChartView *ccc = [cell.contentView viewWithTag:1];
//        if (isLoad == NO&&dischargeArray.count)
//            isLoad = YES;
//        if (isLoad) {
            if (dischargeArray.count == 0) {
                if (![cell.contentView viewWithTag:100]) {
                    UIView *placeHolderView = [[UIView alloc] initWithFrame:ccc.frame];
                    placeHolderView.backgroundColor = [UIColor whiteColor];
                    placeHolderView.tag = 100;
                    [cell.contentView addSubview:placeHolderView];
                }
            }
            else
            {
                UIView *placeHolderView = [cell.contentView viewWithTag:100];
                if (placeHolderView) {
                    [placeHolderView removeFromSuperview];
                }
                placeHolderView = nil;
            }
//        }

    
//        ccc.backgroundColor = [UIColor greenColor];
//        NSLog(@"ccc---%@",NSStringFromCGRect(ccc.frame));
//        if (isLoad == NO) {
//            isLoad = YES;
            ccc.yAxisViewWidth = 52;
            ccc.numberOfYAxisElements = 5;
            ccc.yAxisMaxValue = 15;
            ccc.pointGap = 50;
            
            ccc.showSeparate = YES;
            ccc.separateColor = RGB(0x67707c);
//            ccc.showPointLabel = YES;
        
            //        ccc.textColor = RGB(0x9aafc1);
            ccc.backColor = [UIColor whiteColor];//RGB(0x3e4a59);
            ccc.axisColor = RGB(0x67707c);//RGB(0x67707c);

//        }
        

        ccc.xAxisTitleArray = [self arrayWithDicArray:dischargeArray key:@"Time"];
        ccc.index = dischargeArray.count;
        
        DVPlot *plot = [[DVPlot alloc] init];

        NSArray *keyArray = @[@"Voltage",@"Current",@"Capacity"];
        NSString *key = keyArray[currentYIndex];
        plot.pointArray = [self arrayWithDicArray:dischargeArray key:key];
        plot.lineColor = themeColor;//RGB(0x2f7184);
        plot.pointColor = RGB(0x14b9d6);
        plot.pointSelectedColor = RGB(0x14b9d6);
        plot.chartViewFill = YES;
        plot.withPoint = YES;
        
        [ccc addPlot:plot];
        [ccc draw];

        
        TLTagsControl *tagsControl = [cell.contentView viewWithTag:2];
        [tagsControl setTapDelegate:self];
        tagsControl.mode = TLTagsControlModeList;
        tagsControl.tags = @[@"电压",@"电流",@"容量"];
        [tagsControl reloadTagSubviews];
        [tagsControl setTagSubviewWithIndex:currentYIndex];
        
        NSArray *unitArray = @[@"Vdc",@"Adc",@"AH"];
        UILabel *unitLabel = [cell.contentView viewWithTag:3];
        unitLabel.text = unitArray[currentYIndex];
        
        BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
        UILabel *numberLabel = [cell.contentView viewWithTag:4];
        if (batteryGroup.batteryNumber!=0) {
            numberLabel.text = [NSString stringWithFormat:@"#%@",batteryGroup.batteryNumber];
        }
        else
            numberLabel.text = @"编号";
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"normalCell"];
        }
        //取出对象
        BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
        
        NSString *dischargeOutputVoltage = NSLocalizedString(@"dischargeOutputVoltage", nil);
//        NSString *dischargeOutputCurrent = NSLocalizedString(@"dischargeOutputCurrent", nil);
        NSString *batteryDischargeCapacity = NSLocalizedString(@"batteryDischargeCapacity", nil);
        NSString *actualDischargePeriod = NSLocalizedString(@"actualDischargePeriod", nil);
        
        NSArray *array = @[@[dischargeOutputVoltage,@"dischargeVoltage",@"Vdc",@"voltageIcon"],
//                           @[dischargeOutputCurrent,@"dischargeCurrent",@"Adc",@"currentIcon"],
                           @[batteryDischargeCapacity,@"dischargeCapacity",@"AH",@"elecIcon"],
                           @[actualDischargePeriod,@"",@"",@"time"]
                        ];
        cell.textLabel.text = [array[indexPath.row] firstObject];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        if (indexPath.row != array.count-1) {
            NSString *valueName = [array[indexPath.row] objectAtIndex:1];
            NSString *value = [[batteryGroup valueForKey:valueName] description];
            
            if (value == nil) {
                cell.detailTextLabel.text = @"--";
            }
            else
            {
                NSString *unit = [array[indexPath.row] objectAtIndex:2];
                cell.detailTextLabel.text =[value stringByAppendingString:unit];
            }
//            NSString *unit = [array[indexPath.row] objectAtIndex:2];
//            cell.detailTextLabel.text =[value stringByAppendingString:unit];
            NSString *iconName = [array[indexPath.row] objectAtIndex:3];
            cell.imageView.image = [UIImage imageNamed:iconName];

        }
        else
        {
            NSString *hour = [batteryGroup valueForKey:@"hour"];
            NSString *minute = [batteryGroup valueForKey:@"minute"];
            NSString *second = [batteryGroup valueForKey:@"second"];
            NSString *time = [NSString stringWithFormat:@"%@时%@分%@秒",hour,minute,second];
            if (hour == nil) {
                time = nil;
                cell.detailTextLabel.text = @"--";
            }
            else
                cell.detailTextLabel.text = time;
            NSString *iconName = [array[indexPath.row] objectAtIndex:3];
            cell.imageView.image = [UIImage imageNamed:iconName];
        }
        
    }
    return cell;
}
- (NSArray *)arrayWithDicArray:(NSArray *)array key:(NSString *)key
{
    NSMutableArray *mArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        [mArray addObject:dic[key]];
    }
    return mArray;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![MemDataManager shareManager].isIntranet && indexPath.section==2)
    {
        return 44;
    }
    if (indexPath.section == 2) {
        return 280;
    }
    else
        return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = @[@"操作",@"参数",@"曲线"];
    if (![MemDataManager shareManager].isIntranet && section==2)
    {
        return @"编号";
    }
    return array[section];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 2) {
//        return 30;
//    }
//    else
//        return 18;
//}
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
//    NSString *title;
//    switch (section) {
//        case 0:
//            title = NSLocalizedString(@"userControl", nil);
//            break;
//        case 1:
//            title = NSLocalizedString(@"electricityParameters", nil);
//            break;
//        case 2:
//            title = @"放电曲线";
//            break;
//        default:
//            break;
//    }
//    detailLabel.text = title;
//    
//    return myHeader;
//}
#pragma mark - TLTagsControlDelegate
- (void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index {
    if (currentYIndex == index) //点中原来的tag
    {
        return;
    }
    currentYIndex = index;
    [tagsControl setTagSubviewWithIndex:index];
    //更新界面
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

}
#pragma mark -  Action
- (void)controlBtnClicked:(UIButton *)sender
{
    //取出对象
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSUInteger index = [[self.tableView indexPathForCell:cell] row]+1;

   
//    if (sender.tag == 1) { //开始
//        [[BatteryManager shareManager] AutoCalibrationOfBattery:batteryGroup start:YES];
//        [mbHud showWithTitle:@"开始校准" detail:nil];
//        [mbHud hide:YES afterDelay:1];
//
//    }
//    else if(sender.tag == 2){
//        [[BatteryManager shareManager] AutoCalibrationOfBattery:batteryGroup start:NO];
//        [mbHud showWithTitle:@"停止校准" detail:nil];
//        [mbHud hide:YES afterDelay:1];
//    }
    if (sender.tag%2 == 1) { //开始
        
        if ([MemDataManager shareManager].isIntranet) {
            [[BatteryManager shareManager] disChargeBattery:batteryGroup number:index start:YES];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [BatteryService insertDisChargeOrderAddr:batteryGroup.address number:index isStart:YES];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
//                    isDischargeSuccess = NO;
//                    [[MemDataManager shareManager] updataRealData];
//                });
            });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                isDischargeSuccess = NO;
                 if (![MemDataManager shareManager].isIntranet) {
                     [[MemDataManager shareManager] updataRealData];
                 }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (![MemDataManager shareManager].isIntranet) {
                        [[MemDataManager shareManager] updataRealData];
                    }

                    
                });
            });
        }

        [mbHud showWithTitle:[NSString stringWithFormat:@"开始放电-电池#%lu",(unsigned long)index] detail:nil];
        [mbHud hide:YES afterDelay:1];
    }
    else //if (sender.tag%2== 0)
    {
        [[BatteryManager shareManager] disChargeBattery:batteryGroup number:index start:NO];
        if ([MemDataManager shareManager].isIntranet) {
            [[BatteryManager shareManager] disChargeBattery:batteryGroup number:index start:NO];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [BatteryService insertDisChargeOrderAddr:batteryGroup.address number:index isStart:NO];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
//                    isDischargeSuccess = NO;
//                    [[MemDataManager shareManager] updataRealData];
//                });
            });
//
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                isDischargeSuccess = NO;
                if (![MemDataManager shareManager].isIntranet) {
                    [[MemDataManager shareManager] updataRealData];
                }

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (![MemDataManager shareManager].isIntranet) {
                        [[MemDataManager shareManager] updataRealData];
                    }
                });

            });
        }

        [mbHud showWithTitle:[NSString stringWithFormat:@"停止放电-电池#%lu",(unsigned long)index] detail:nil];
        [mbHud hide:YES afterDelay:1];
    }


}
- (IBAction)displayExtra:(id)sender {
    //取出对象
    BatteryGroup *batteryGroup = [MemDataManager shareManager].currentGroup;
    NSString *value = [batteryGroup.dischargeCurrent description];
    [mbHud showWithTitle:@"放电电流" detail:value];
}

- (IBAction)clearChart:(id)sender {
    [dischargeArray removeAllObjects];
    //更新界面
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 1)] withRowAnimation:UITableViewRowAnimationNone];
}
@end
