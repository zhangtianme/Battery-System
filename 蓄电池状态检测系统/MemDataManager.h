//
//  MemDataManager.h
//  蓄电池系统
//
//  Created by 张天 on 2016/12/8.
//  Copyright © 2016年 张天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BatteryGroup.h"

@protocol MemDataDelegate <NSObject>
@optional
- (void)serviceDidReceiveData;
@end

@interface MemDataManager : NSObject
+ (MemDataManager *)shareManager;
- (void)readPlist;
- (void)updateGroupData:(NSArray *)data;

- (void)updataRealData;
@property (nonatomic,weak) id<MemDataDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *groupArray; //电池组数组
@property (nonatomic,assign) NSUInteger currentIndex; //当前电池组index
@property (nonatomic,assign) BOOL isIntranet;   //是否为内网模式
@property(nonatomic,retain) BatteryGroup *currentGroup;

@end
