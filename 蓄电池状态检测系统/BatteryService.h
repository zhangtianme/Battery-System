//
//  BatteryService.h
//  蓄电池系统
//
//  Created by 张天 on 2016/12/14.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatteryService : NSObject
+ (BatteryService *)shareService;
+ (NSArray *)inquiryPack;
+ (NSArray *)inquiryAttributeDescription;
+ (NSDictionary *)inquiryPackRealDataWithAddr:(NSString *)addr;
+ (NSArray *)inquirySubRealDataWithAddr:(NSString *)addr;
+ (NSString *)insertChargeOrderAddr:(NSUInteger)addr number:(int)number isStart:(BOOL)isStart;
+ (NSString *)insertDisChargeOrderAddr:(NSUInteger)addr number:(int)number isStart:(BOOL)isStart;
+ (NSArray *)inquiryPackHisData:(NSArray *)paraArray;
+ (NSArray *)inquirySubHisData:(NSArray *)paraArray;
@end
