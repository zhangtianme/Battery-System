//
//  Battery.h
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatteryManager.h"
#import "GCDAsyncSocket.h"
@interface Battery : NSObject
//预测数据
@property(nonatomic,retain) NSNumber *voltage;
@property(nonatomic,retain) NSNumber *internalRes;
@property(nonatomic,retain) NSNumber *maxCurrent;
@property(nonatomic,retain) NSNumber *healthState;
@property(nonatomic,retain) NSNumber *capacity;
@property(nonatomic,retain) NSNumber *currentEnergy;
//充电数据
@property(nonatomic,retain) NSNumber *chargeVoltage;
@property(nonatomic,retain) NSNumber *chargeCurrent;
@property(nonatomic,retain) NSNumber *chargeEnergy;
@property(assign)BOOL state;
@end
