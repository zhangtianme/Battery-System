//
//  HisDataViewController.m
//  三川智能水利
//
//  Created by 张天 on 16/4/18.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "HisDataViewController.h"
#import "Define.h"
#import "BEMSimpleLineGraphView.h"
#import "BatteryService.h"
#define DayFreq @"1"
#define OtherFreq @"24"

@interface HisDataViewController ()<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSArray *hisDataArray;
    MBProgressHUD *mbHud;
    NSUInteger segementedIndex; //segementedcontrol选中的index
    NSString *popUpPrefix;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) BEMSimpleLineGraphView *myGraph;
@end

@implementation HisDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    
}
- (void)dealloc
{
    NSLog(@"%@--dealloc",self);
}
- (void)initViews
{
    self.title = _paramDic[@"name"];
    // 初始化指示器
    if (!mbHud) {
        mbHud = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:mbHud];
        mbHud.dimBackground = YES;

    }
    //初始化segmentedControl
    UIView *segmentedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    segmentedView.backgroundColor = themeColor;
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"日",@"周",@"月"]];
    segmentedControl.frame = CGRectMake(0, 0, ScreenWidth*4/5, 30);
    segmentedControl.tintColor = [UIColor whiteColor];
    segmentedControl.center = segmentedView.center;
    [segmentedView addSubview:segmentedControl];
    [self.view addSubview:segmentedView];
    //默认选择周
    segementedIndex = 1;
    [segmentedControl setSelectedSegmentIndex:segementedIndex];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self networkRequest];
    //创建BEMSimpleLineGraphView
    _myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, segmentedView.height, ScreenWidth, 200)];
    _myGraph.dataSource = self;
    _myGraph.delegate = self;
    [self.view addSubview:_myGraph];
    _myGraph.colorBottom = themeColor;
    _myGraph.colorTop = themeColor;

    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.enableYAxisLabel = YES;
    self.myGraph.autoScaleYAxis = YES;
    self.myGraph.alwaysDisplayDots = NO;
    self.myGraph.enableReferenceXAxisLines = YES;
    self.myGraph.enableReferenceYAxisLines = YES;
    self.myGraph.enableReferenceAxisFrame = YES;
    
    self.myGraph.colorYaxisLabel = [UIColor whiteColor]; // YLabel白色
    self.myGraph.colorXaxisLabel = [UIColor whiteColor]; // XLabel白色
    // Dash the y reference lines
    self.myGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    // Show the y axis values with this format string
    self.myGraph.formatStringForValues = @"%.1f";
    self.myGraph.backgroundColor = matchColor;
    
    //tableview显示详细信息
    float tableViewY = segmentedView.height + _myGraph.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY,ScreenWidth, ScreenHeight - tableViewY-64) style:UITableViewStylePlain];//去掉导航栏和状态栏的高度，不然tableview下面显示不全
    _tableView.backgroundColor = matchColor;
    _tableView.tableFooterView = [UIView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init]; // 去除多余空白行
    [self.view addSubview:_tableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //去掉导航栏下面的黑线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
#pragma mark -  networkRequest
- (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:00"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
    
}

- (void)networkRequest
{
    //获取时间信息
    NSString *endTime;
    NSString *startTime;
    //天
    if (segementedIndex == 0) {
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:00"];
        NSDate *nextHourDay = [NSDate dateWithTimeInterval:60*60 sinceDate:[NSDate date]];
        endTime = [formatter stringFromDate:nextHourDay];
        
        NSDate *lastDay = [NSDate dateWithTimeInterval:-23*60*60 sinceDate:[NSDate date]];
        startTime = [formatter stringFromDate:lastDay];
    }
    //周
    else if (segementedIndex == 1) {
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *tomorrowDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
        endTime = [formatter stringFromDate:tomorrowDay];
        
        NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60*6 sinceDate:[NSDate date]];
        startTime = [formatter stringFromDate:lastDay];
    }
    //月
    else
    {
        NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *tomorrowDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]];
        endTime = [formatter stringFromDate:tomorrowDay];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = nil;
        comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        [adcomps setMonth:-1];
        [adcomps setDay:1];
        NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
        startTime = [formatter stringFromDate:newdate];
    }
    NSString *freq = segementedIndex==0?DayFreq:OtherFreq;
    [mbHud showWithTitle:@"加载中..." detail:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array;
        //通知主线程刷新
        if ([_paramDic[@"isPack"] isEqualToString:@"0"]) {
            NSArray *paraArray = @[@{@"BID":_paramDic[@"BID"]},
                                   @{@"Number":_paramDic[@"Number"]},
                                   @{@"Para":_paramDic[@"Para"]},
                                   @{@"StartTime":startTime},
                                   @{@"EndTime":endTime}
                                  ];
            
           array =  [BatteryService inquirySubHisData:paraArray];
        }
        else
        {
            NSArray *paraArray = @[@{@"BID":_paramDic[@"BID"]},
                                   @{@"Para":_paramDic[@"Para"]},
                                   @{@"StartTime":startTime},
                                   @{@"EndTime":endTime}
                                   ];
            
            array =  [BatteryService inquiryPackHisData:paraArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//        if (array)
//        {
//            [mbHud hide:YES];
//        }
//        else
//        {
//            [mbHud showWithTitle:@"未收到数据，请重试" detail:nil];
//            [mbHud hide:YES afterDelay:1];
//        }
            [mbHud hide:YES];
            hisDataArray = array;
            [_myGraph reloadGraph];
            [self.tableView reloadData];
        });
    });
}
#pragma mark -  Action Methods
-(void)segmentAction:(UISegmentedControl *)seg{
    segementedIndex = seg.selectedSegmentIndex;
    [self networkRequest];
}
#pragma mark -  tableView DateSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (hisDataArray == nil) {
        return 0;
    }
    return hisDataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentity = @"DromCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentity];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentity];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSDictionary *dataDic = [hisDataArray objectAtIndex:indexPath.row];
    NSArray *allKeys = [dataDic allKeys];
    NSString *date;
    if ([allKeys containsObject:@"GetTime"]){
        date = [[dataDic valueForKey:@"GetTime"] substringToIndex:16];
        if (segementedIndex!=0)
            date = [[dataDic valueForKey:@"GetTime"] substringToIndex:10];// 周和月的时间只显示到天
        if (segementedIndex==0)
            date = [date stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
//    if (![dataDic[@"Unit"] isEqualToString:@"1"]) {
//        cell.textLabel.text = [dataDic[@"Value"] stringByAppendingString:dataDic[@"Unit"]];
//    }
//    else
    cell.textLabel.text = dataDic[@"Value"];
    
    cell.textLabel.text = [dataDic[@"Value"] stringByAppendingString:_paramDic[@"Unit"]];
    cell.detailTextLabel.text = date;
    return cell;
}
#pragma mark -  tableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //去掉选中效果
}
#pragma mark -  SimpleLineGraph Data Source
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    if (hisDataArray == nil) {
        return 0;
    }
    return hisDataArray.count;
}
- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    CGFloat value =  [[[hisDataArray objectAtIndex:index] valueForKey:@"Value"] doubleValue];
    return value;
}

#pragma mark - SimpleLineGraph Delegate
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    if (hisDataArray == nil) {
        return 1;
    }
    return hisDataArray.count;
}
- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self stringDateFromIndex:index];
    return label;
}
- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    popUpPrefix = [NSString stringWithFormat:@"%@ ",[self stringDateFromIndex:index]];
}
// 点击图标显示的附加后缀
- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return _paramDic[@"Unit"];
}
// 点击图标显示的附加前缀
- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
    if (!popUpPrefix) { // 为空
        popUpPrefix = @"00000";// 要先确定触摸显示的前缀的大概字符
        
    }
    return popUpPrefix;
}
// 根据索引显示日期 周日月不一样
- (NSString *)stringDateFromIndex:(NSInteger)index {
    NSDictionary *aValue = [hisDataArray objectAtIndex:index];
    NSArray *allKeys = [aValue allKeys];
    NSString *date;
    if ([allKeys containsObject:@"GetTime"]){
        date = [[aValue valueForKey:@"GetTime"] substringToIndex:16];
        if (segementedIndex!=0)// 周和月的时间Label
            date = [date substringWithRange:NSMakeRange(5, 5)];
        else
            date = [date substringWithRange:NSMakeRange(11, 5)];
    }
    return date;
}

@end
