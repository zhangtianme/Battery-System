//
//  BatteryGroup.m
//  蓄电池系统
//
//  Created by 张天 on 2016/11/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "BatteryGroup.h"

@implementation BatteryGroup
-(GCDAsyncSocket *)socket
{
    if (_socket == nil) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:[BatteryManager shareManager] delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}
- (NSArray<Battery *> *)batterys
{
    if (_batterys == nil) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<4; i++) {
            Battery *b = [[Battery alloc] init];
            [array addObject:b];
        }
        _batterys = [NSArray arrayWithArray:array];
    }
    return _batterys;
}
@end
