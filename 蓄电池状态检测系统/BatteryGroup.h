//
//  BatteryGroup.h
//  蓄电池系统
//
//  Created by 张天 on 2016/11/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatteryManager.h"
#import "GCDAsyncSocket.h"
//#import "Battery.h"
@class Battery;
@interface BatteryGroup : NSObject
@property (nonatomic,retain)GCDAsyncSocket *socket;
@property (nonatomic,retain)NSString *ip;
@property (nonatomic,retain)NSString *name;
@property (nonatomic,assign)NSUInteger port;


@property (nonatomic,assign)NSUInteger address;
@property (nonatomic,assign)NSString *bid;
@property (nonatomic,strong) NSArray<Battery *> *batterys;

@property(nonatomic,retain) NSNumber *acVoltage;
@property(nonatomic,retain) NSNumber *acCurrent;
@property(nonatomic,retain) NSNumber *power;
@property(nonatomic,retain) NSNumber *powerFactor;
@property(nonatomic,retain) NSNumber *powerConsumption;

@property(nonatomic,retain) NSNumber *chargeVoltage;
@property(nonatomic,retain) NSNumber *chargeCurrent;
@property(assign)BOOL state;

//连续放电
@property(nonatomic,retain) NSNumber *dischargeVoltage;
@property(nonatomic,retain) NSNumber *dischargeCurrent;
@property(nonatomic,retain) NSNumber *dischargeCapacity;
@property(nonatomic,retain) NSNumber *hour;
@property(nonatomic,retain) NSNumber *minute;
@property(nonatomic,retain) NSNumber *second;

//参数
@property(nonatomic,retain) NSNumber *nominalCapacity;
@property(nonatomic,retain) NSNumber *singleVoltage;
@property(nonatomic,retain) NSNumber *cutoffVoltage;
@property(nonatomic,retain) NSNumber *batteryNumber;
@property(nonatomic,retain) NSNumber *workState;
@property(nonatomic,retain) NSNumber *isMaintain;
//@property(nonatomic,retain) NSNumber *dischargeCurrentPara;
@end
