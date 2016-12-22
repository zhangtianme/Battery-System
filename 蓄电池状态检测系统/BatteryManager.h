//
//  BatteryManager.h
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"

@protocol BatteryManagerDelegate <NSObject>
@optional
- (void)managerDidReceiveData;
- (void)managerDidReceiveReferenceValue:(NSDictionary *)dic;
- (void)managerDidReceiveDischargeValue:(NSDictionary *)dic;
@end

@class BatteryGroup;
@interface BatteryManager : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic,weak) id<BatteryManagerDelegate> delegate;
//@property(nonatomic,retain)BatteryGroup *batteryGroup;

+ (BatteryManager *)shareManager;

//读取预测数据
- (void)readPredictedDataOfBattery:(BatteryGroup *)batteryGroup;
//充电
- (void)readChargeBatteryGroup:(BatteryGroup *)batteryGroup;

- (void)chargeBattery:(BatteryGroup *)batteryGroup number:(NSUInteger)number start:(BOOL)start;
//放电
- (void)disChargeBattery:(BatteryGroup *)batteryGroup number:(NSUInteger)number start:(BOOL)start;
//读取参数
- (void)readParaOfBattery:(BatteryGroup *)batteryGroup;
//设定参数
- (void)setParaOfBattery:(BatteryGroup *)batteryGroup batteryNumber:(NSNumber *)batteryNumber nominalCapacity:(NSNumber *)nominalCapacity singleVoltage:(NSNumber *)singleVoltage cutoffVoltage:(NSNumber *)cutoffVoltage isMaintain:(NSNumber *)isMaintain;
//自动校准
- (void)AutoCalibrationOfBattery:(BatteryGroup *)batteryGroup start:(BOOL)start;
//读取参考值
- (void)readReferenceValue:(BatteryGroup *)batteryGroup;
//设置参考值
- (void)updateReferenceValue:(BatteryGroup *)batteryGroup;





////开始充电
//- (void)startChargeOfBattery:(Battery *)battery;
////停止充电
//- (void)stopChargeOfBattery:(Battery *)battery;
////开始放电
//- (void)startDischargeOfBattery:(Battery *)battery;
////停止充电
//- (void)stopDischargeOfBattery:(Battery *)battery;
@end
