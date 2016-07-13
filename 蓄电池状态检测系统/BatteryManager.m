//
//  BatteryManager.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "BatteryManager.h"

#define WriteTimeout 3
#define deviceAddress 0x01

@implementation BatteryManager
#pragma mark -  单例模式
+ (BatteryManager *)shareManager
{
    static BatteryManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
    });
    return shareManager;
}
#pragma mark - 外部接口
- (void)readPredictedDataOfBattery:(Battery *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,deviceAddress,2,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)startChargeOfBattery:(Battery *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,deviceAddress,3,3,1,0,0};
    //CRC校验
    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:7];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)stopChargeOfBattery:(Battery *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,deviceAddress,3,3,0,0,0};
    //CRC校验
    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:7];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)startDischargeOfBattery:(Battery *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,deviceAddress,4,3,1,0,0};
    //CRC校验
    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:7];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)stopDischargeOfBattery:(Battery *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,deviceAddress,4,3,0,0,0};
    //CRC校验
    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:7];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)readParaOfBattery:(Battery *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,deviceAddress,5,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)setParaOfBattery:(Battery *)battery nominalCapacity:(NSNumber *)nominalCapacity
           singleVoltage:(NSNumber *)singleVoltage cutoffVoltage:(NSNumber *)cutoffVoltage
    dischargeCurrentPara:(NSNumber *)dischargeCurrentPara
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //取出参数
    Byte nominalCapacity_H = nominalCapacity.intValue/256;
    Byte nominalCapacity_L = nominalCapacity.intValue%256;
    Byte singleVoltage_H = singleVoltage.intValue/256;
    Byte singleVoltage_L = singleVoltage.intValue%256;
    Byte cutoffVoltage_H = (int)(cutoffVoltage.floatValue*10)/256;
    Byte cutoffVoltage_L = (int)(cutoffVoltage.floatValue*10)%256;
    Byte dischargeCurrentPara_H = (int)(dischargeCurrentPara.floatValue*10)/256;
    Byte dischargeCurrentPara_L = (int)(dischargeCurrentPara.floatValue*10)%256;
    //数据封装
    Byte data[]={0xAA,deviceAddress,6,0x0A,nominalCapacity_H,nominalCapacity_L,singleVoltage_H,singleVoltage_L,cutoffVoltage_H,cutoffVoltage_L,dischargeCurrentPara_H,dischargeCurrentPara_L,0,0};
    //CRC校验
    data[12] = [self getCRC16Code:data withNumber:12 fromIndex:0]%256;//CRC_L
    data[13] = [self getCRC16Code:data withNumber:12 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:14];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
#pragma mark -  GCDAsyncSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:10];
    //根据功能码解析数据
    if (data.length<6) {
        return;
    }
    //取出对象
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Battery *battery = appDelegate.battery;
    //取功能码
    Byte *functionCodeBytes =(Byte *) [[data subdataWithRange:NSMakeRange(2, 1)] bytes];
    int functionCode = functionCodeBytes[0];
    switch (functionCode) {
        case 2: //预测数据
        {
            if (data.length<20) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 20)];
            //CRC校验
            if (![self isDataFitCRC16:validData]) {
                return;
            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 14)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            battery.voltage = [NSNumber numberWithFloat: 0.001*(allData[0]*256 + allData[1])];
            battery.current = [NSNumber numberWithFloat: 0.001*(allData[2]*256 + allData[3])];
            battery.internalRes = [NSNumber numberWithFloat: 0.1*(allData[4]*256 + allData[5])];
            battery.maxCurrent = [NSNumber numberWithFloat: (allData[6]*256 + allData[7])];
            battery.healthState = [NSNumber numberWithFloat: (allData[8]*256 + allData[9])];
            battery.capacity = [NSNumber numberWithFloat: 0.1*(allData[10]*256 + allData[11])];
            battery.currentEnergy = [NSNumber numberWithFloat: (allData[12]*256 + allData[13])];
            if ([self.delegate respondsToSelector:@selector(managerDidReceiveData)]) {
                [self.delegate managerDidReceiveData];
            }
        }
            break;
        case 3: //充电数据
        {
            if (data.length<22) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 22)];
            //CRC校验
//            if (![self isDataFitCRC16:validData]) {
//                return;
//            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 16)];
            Byte *allData = (Byte *)[dataContent bytes];
           
            battery.acVoltage = [NSNumber numberWithFloat: (allData[0]*256 + allData[1])];
            battery.acCurrent = [NSNumber numberWithFloat: 0.01*(allData[2]*256 + allData[3])];
            battery.power = [NSNumber numberWithFloat: 0.1*(allData[4]*256 + allData[5])];
            battery.powerFactor = [NSNumber numberWithFloat: 0.001*(allData[6]*256 + allData[7])];
            battery.powerConsumption = [NSNumber numberWithFloat: 0.1*(allData[8]*256 + allData[9])];
            battery.chargeVoltage = [NSNumber numberWithFloat: 0.01*(allData[10]*256 + allData[11])];
            battery.chargeCurrent = [NSNumber numberWithFloat: 0.001*(allData[12]*256 + allData[13])];
            battery.chargeEnergy = [NSNumber numberWithFloat: 0.01*(allData[14]*256 + allData[15])];
            if ([self.delegate respondsToSelector:@selector(managerDidReceiveData)]) {
                [self.delegate managerDidReceiveData];
            }

        }
            break;
        case 4: //连续放电
        {
            if (data.length<16) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 16)];
            //CRC校验
//            if (![self isDataFitCRC16:validData]) {
//                return;
//            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 10)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            battery.dischargeVoltage = [NSNumber numberWithFloat: 0.01*(allData[0]*256 + allData[1])];
            battery.dischargeCurrent = [NSNumber numberWithFloat: 0.01*(allData[2]*256 + allData[3])];
            battery.dischargeCapacity = [NSNumber numberWithFloat: 0.1*(allData[4]*256 + allData[5])];
        
            battery.hour = [NSNumber numberWithInt:allData[7]];
            battery.minute = [NSNumber numberWithInt:allData[8]];
            battery.second = [NSNumber numberWithInt:allData[9]];
            if ([self.delegate respondsToSelector:@selector(managerDidReceiveData)]) {
                [self.delegate managerDidReceiveData];
            }

        }
            break;
        case 5: //读取参数
        {
            if (data.length<14) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 14)];
            //CRC校验
//            if (![self isDataFitCRC16:validData]) {
//                return;
//            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 8)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            battery.nominalCapacity = [NSNumber numberWithFloat: (allData[0]*256 + allData[1])];
            battery.singleVoltage = [NSNumber numberWithFloat:(allData[2]*256 + allData[3])];
            battery.cutoffVoltage = [NSNumber numberWithFloat:0.1*(allData[4]*256 + allData[5])];
            battery.dischargeCurrentPara = [NSNumber numberWithFloat: 0.1*(allData[6]*256 + allData[7])];
            if ([self.delegate respondsToSelector:@selector(managerDidReceiveData)]) {
                [self.delegate managerDidReceiveData];
            }

        }
            break;
        case 6: //设定参数
        {
            if (data.length<6) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 6)];
            //CRC校验
            if (![self isDataFitCRC16:validData]) {
                return;
            }
        }
        default:
            break;
    }
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    [sock readDataWithTimeout:-1 tag:10];
}
#pragma mark CRC Check
//判断CRC校验是否正确
- (BOOL)isDataFitCRC16:(NSData *)data
{
    uint16_t CRC_SEED = 0XFFFF;
    uint16_t CRC16Poly = 0XA001;
    uint16_t CRCReg = CRC_SEED;
    
    uint16_t length = [data length];
    Byte *byteData = (Byte *)[data bytes];
    
    for (int i = 0; i < length; i++) {
        CRCReg ^= byteData[i];
        
        for (int j = 0; j < 8; j++) {
            if (CRCReg & 0x0001) {
                CRCReg = (CRCReg >> 1) ^ CRC16Poly;
            } else {
                CRCReg = CRCReg >> 1;
            }
        }
    }
    
    if (CRCReg == 0) {
        return YES;
    } else {
        return NO;
    }
    
}
//获取16位CRC校验码
- (uint16_t)getCRC16Code:(Byte *)uint8Array withNumber:(uint16_t)number fromIndex:(uint16_t)index
{
    uint16_t CRC_SEED = 0XFFFF;
    uint16_t CRC16Poly = 0XA001;
    uint16_t CRCReg = CRC_SEED;
    
    for (int i = 0; i < number; i++) {
        
        CRCReg ^= uint8Array[i+index];
        for (int j = 0; j < 8; j++) {
            if (CRCReg & 0x0001) {
                CRCReg = (CRCReg >> 1) ^ CRC16Poly;
            } else {
                CRCReg = CRCReg >> 1;
            }
        }
    }
    
    return CRCReg;
}
@end
