//
//  BatteryManager.h
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define.h"
@class Battery;

@protocol BatteryManagerDelegate <NSObject>
@optional
- (void)managerDidReceiveData;

@end

@interface BatteryManager : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic,weak) id<BatteryManagerDelegate> delegate;
+ (BatteryManager *)shareManager;

//读取预测数据
- (void)readPredictedDataOfBattery:(Battery *)battery;
//开始充电
- (void)startChargeOfBattery:(Battery *)battery;
//停止充电
- (void)stopChargeOfBattery:(Battery *)battery;
//开始放电
- (void)startDischargeOfBattery:(Battery *)battery;
//停止充电
- (void)stopDischargeOfBattery:(Battery *)battery;
//读取参数
- (void)readParaOfBattery:(Battery *)battery;
//设定参数
- (void)setParaOfBattery:(Battery *)battery nominalCapacity:(NSNumber *)nominalCapacity singleVoltage:(NSNumber *)singleVoltage cutoffVoltage:(NSNumber *)cutoffVoltage dischargeCurrentPara:(NSNumber *)dischargeCurrentPara;

@end
