//
//  BatteryManager.h
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
@class BatteryGroup;

@protocol BatteryManagerDelegate <NSObject>
@optional
- (void)managerDidReceiveData;
- (void)managerDidReceiveReferenceValue:(NSDictionary *)dic;
- (void)managerDidReceiveDischargeValue:(NSDictionary *)dic;
@end

@interface BatteryManager : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic,weak) id<BatteryManagerDelegate> delegate;
+ (BatteryManager *)shareManager;

//读取预测数据
- (void)readPredictedDataOfBattery:(BatteryGroup *)batteryGroup;
//充电
- (void)readChargeBatteryGroup:(BatteryGroup *)batteryGroup;

- (void)chargeBattery:(BatteryGroup *)batteryGroup number:(NSUInteger)number start:(BOOL)start;
//放电
- (void)disChargeBattery:(BatteryGroup *)battery number:(NSUInteger)number start:(BOOL)start;
//读取参数
- (void)readParaOfBattery:(BatteryGroup *)battery;
//设定参数
- (void)setParaOfBattery:(BatteryGroup *)battery batteryNumber:(NSNumber *)batteryNumber nominalCapacity:(NSNumber *)nominalCapacity singleVoltage:(NSNumber *)singleVoltage cutoffVoltage:(NSNumber *)cutoffVoltage isMaintain:(NSNumber *)isMaintain;
//自动校准
- (void)AutoCalibrationOfBattery:(BatteryGroup *)battery start:(BOOL)start;
//读取参考值
- (void)readReferenceValue:(BatteryGroup *)battery;
//设置参考值
- (void)updateReferenceValue:(BatteryGroup *)battery;





////开始充电
//- (void)startChargeOfBattery:(Battery *)battery;
////停止充电
//- (void)stopChargeOfBattery:(Battery *)battery;
////开始放电
//- (void)startDischargeOfBattery:(Battery *)battery;
////停止充电
//- (void)stopDischargeOfBattery:(Battery *)battery;
@end
