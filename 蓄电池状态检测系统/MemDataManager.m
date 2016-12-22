//
//  MemDataManager.m
//  蓄电池系统
//
//  Created by 张天 on 2016/12/8.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "MemDataManager.h"
#import "BatteryGroup.h"
#import "BatteryService.h"
@implementation MemDataManager
+ (MemDataManager *)shareManager
{
    static MemDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
- (instancetype)init
{
    if (self == nil) {
        self = [super init];
    }
    _currentIndex = 0;
    return self;
}
- (BOOL)isIntranet
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"NetMode"];
    if (number == nil) {
        return 0;
    }
    else
        return number.boolValue;
}
- (BatteryGroup *)currentGroup
{
    if (_groupArray == nil) {
        return nil;
    }
    else
    {
        _currentGroup = _groupArray[_currentIndex];
        return _currentGroup;
    }
}

- (NSMutableArray *)groupArray
{
    if(_groupArray == nil)
    {
        _groupArray = [NSMutableArray array];
    }
    return _groupArray;
}
- (void)readPlist
{
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"plistSBMS" ofType:@"plist"];
//    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    NSMutableArray *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"battery"];
    if (data == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"plistSBMS" ofType:@"plist"];
        data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    }
    NSMutableArray *oldGroupArray = [NSMutableArray array];
    //取值替换
    for (NSDictionary *dic in data) {
        BatteryGroup *group =  [[BatteryGroup alloc] init];
        group.bid = dic[@"BID"];
        group.name = dic[@"BName"];
        group.address =  [dic[@"BAddr"] integerValue];
        group.batteryNumber = @1;
//        group.ip =  dic[@"ip"];
//        group.port = [dic[@"port"] integerValue];
//        group.name = dic[@"name"];
        [oldGroupArray addObject:group];
    }
    _groupArray = oldGroupArray;
    
}
- (void)updateGroupData:(NSArray *)data
{
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"battery"];
//    //获取应用程序沙盒的Documents目录
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *plistPath1 = [paths objectAtIndex:0];
//    
//    //得到完整的文件名
//    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"plistSBMS.plist"];
//    //输入写入
//    [data writeToFile:filename atomically:YES];
}
- (void)updataRealData
{
//     _currentGroup = _groupArray[_currentIndex];
//    int adress = self.currentGroup.address;
    if (self.currentGroup == nil) {
        return;
    }
   NSDictionary *dic = [BatteryService inquiryPackRealDataWithAddr:self.currentGroup.bid];
    NSArray *array = [BatteryService inquirySubRealDataWithAddr:_currentGroup.bid];
    if (dic!=nil) {
        //写入更新-电池组
        _currentGroup.acVoltage = [NSNumber numberWithFloat:[dic[@"Charge_U"] floatValue]];
        _currentGroup.acCurrent = [NSNumber numberWithFloat:[dic[@"Charge_I"] floatValue]];
        _currentGroup.power = [NSNumber numberWithFloat:[dic[@"power"] floatValue]];
        _currentGroup.powerFactor = [NSNumber numberWithFloat:[dic[@"Charge_PowerRate"] floatValue]];
        _currentGroup.powerConsumption = [NSNumber numberWithFloat:[dic[@"Charge_Electricity"] floatValue]];
        
        _currentGroup.chargeVoltage = [NSNumber numberWithFloat:[dic[@"Pack_U"] floatValue]];
        _currentGroup.chargeCurrent = [NSNumber numberWithFloat:[dic[@"Pack_I"] floatValue]];
        
        _currentGroup.nominalCapacity = [NSNumber numberWithFloat:[dic[@"Pack_Capacity"] floatValue]];
        _currentGroup.singleVoltage = [NSNumber numberWithFloat:[dic[@"Pack_CellU"] floatValue]];
        _currentGroup.cutoffVoltage = [NSNumber numberWithFloat:[dic[@"Pack_CutoffU"] floatValue]];
        _currentGroup.batteryNumber = [NSNumber numberWithInteger:[dic[@"DisCharge_Number"] integerValue]];
        _currentGroup.workState = [NSNumber numberWithInteger:[dic[@"Pack_State"] integerValue]];
        _currentGroup.isMaintain = [NSNumber numberWithInteger:[dic[@"Pack_Maintenancestate"] integerValue]];
    }
   
    if (array != nil) {
        NSDictionary *dicDisCharge;
        if (_currentGroup.batteryNumber.integerValue != 0) {
            dicDisCharge = array[_currentGroup.batteryNumber.integerValue-1];
        }
        if (dicDisCharge[@"Discharge_U"]) {
            _currentGroup.dischargeVoltage = [NSNumber numberWithFloat:[dicDisCharge[@"Discharge_U"] floatValue]];
            _currentGroup.dischargeCurrent = [NSNumber numberWithFloat:[dicDisCharge[@"Discharge_I"] floatValue]];
            _currentGroup.dischargeCapacity = [NSNumber numberWithFloat:[dicDisCharge[@"Discharge_Capacity"] floatValue]];
            
            NSString *time = dicDisCharge[@"Discharge_Time"];
            _currentGroup.hour = [NSNumber numberWithInteger:[[time substringWithRange:NSMakeRange(0, 2)] integerValue]];
            _currentGroup.minute = [NSNumber numberWithInteger:[[time substringWithRange:NSMakeRange(3, 2)] integerValue]];
            _currentGroup.second = [NSNumber numberWithInteger:[[time substringWithRange:NSMakeRange(6, 2)] integerValue]];
        }
        
        //写入更新-电池
        NSUInteger count = array.count<4?array.count:4;
        for (int i=0; i<count; i++) {
            Battery *battery = _currentGroup.batterys[i];
            battery.voltage = [NSNumber numberWithFloat:[array[i][@"Fore_U"] floatValue]];
            battery.internalRes = [NSNumber numberWithFloat:[array[i][@"Fore_R"] floatValue]];
            battery.maxCurrent = [NSNumber numberWithFloat:[array[i][@"Fore_I"] floatValue]];
            battery.healthState = [NSNumber numberWithFloat:[array[i][@"Fore_Health"] floatValue]];
            battery.capacity = [NSNumber numberWithFloat:[array[i][@"Fore_Capacity"] floatValue]];
            battery.currentEnergy = [NSNumber numberWithFloat:[array[i][@"Fore_Electricity"] floatValue]];
            
            battery.chargeVoltage = [NSNumber numberWithFloat:[array[i][@"Charge_U"] floatValue]];
            battery.chargeCurrent = [NSNumber numberWithFloat:[array[i][@"Charge_I"] floatValue]];
            battery.chargeEnergy = [NSNumber numberWithFloat:[array[i][@"Charge_SOC"] floatValue]];
            battery.state = [array[i][@"Charge_State"] boolValue];
            
            battery.getTimeFore = [array[i][@"GetTime_Fore"] substringWithRange:NSMakeRange(11, 5)];
        }
    }
    
     if ([self.delegate respondsToSelector:@selector(serviceDidReceiveData)]) {
        [self.delegate serviceDidReceiveData];
    }
}

@end
