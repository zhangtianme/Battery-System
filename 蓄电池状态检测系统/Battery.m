//
//  Battery.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "Battery.h"

@implementation Battery
-(GCDAsyncSocket *)socket
{
    if (_socket == nil) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:[BatteryManager shareManager] delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}
@end
