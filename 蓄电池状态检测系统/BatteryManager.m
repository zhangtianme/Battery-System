//
//  BatteryManager.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "BatteryManager.h"

#define WriteTimeout 3
//#define deviceAddress 0x01

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
- (void)readPredictedDataOfBattery:(BatteryGroup *)batteryGroup
{
    GCDAsyncSocket *sock = batteryGroup.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    NSLog(@"ip port-----%@---%d",defaultIP,HostPort);
    //数据封装
    Byte data[]={0xAA,batteryGroup.address,2,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)readChargeBatteryGroup:(BatteryGroup *)batteryGroup
{
     GCDAsyncSocket *sock = batteryGroup.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,batteryGroup.address,3,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)chargeBattery:(BatteryGroup *)batteryGroup number:(NSUInteger)number start:(BOOL)start
{
    GCDAsyncSocket *sock = batteryGroup.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,batteryGroup.address,3,4,number,start,0,0};
    //CRC校验
    data[6] = [self getCRC16Code:data withNumber:6 fromIndex:0]%256;//CRC_L
    data[7] = [self getCRC16Code:data withNumber:6 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:8];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)disChargeBattery:(BatteryGroup *)battery number:(NSUInteger)number start:(BOOL)start
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,battery.address,4,4,number,start,0,0};
    //CRC校验
    data[6] = [self getCRC16Code:data withNumber:6 fromIndex:0]%256;//CRC_L
    data[7] = [self getCRC16Code:data withNumber:6 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:8];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
    
}
- (void)readParaOfBattery:(BatteryGroup *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,battery.address,5,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)setParaOfBattery:(BatteryGroup *)battery batteryNumber:(NSNumber *)batteryNumber nominalCapacity:(NSNumber *)nominalCapacity singleVoltage:(NSNumber *)singleVoltage cutoffVoltage:(NSNumber *)cutoffVoltage isMaintain:(NSNumber *)isMaintain
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
    Byte batteryNumberByte = batteryNumber.intValue;
    Byte isMaintainByte = isMaintain.intValue;
    //数据封装
    Byte data[]={0xAA,battery.address,6,0x10,nominalCapacity_H,nominalCapacity_L,singleVoltage_H,singleVoltage_L,cutoffVoltage_H,cutoffVoltage_L,batteryNumberByte,0,isMaintainByte,0,0,0,0,0,0,0};
    //CRC校验
    data[18] = [self getCRC16Code:data withNumber:18 fromIndex:0]%256;//CRC_L
    data[19] = [self getCRC16Code:data withNumber:18 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:20];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
}
- (void)AutoCalibrationOfBattery:(BatteryGroup *)battery start:(BOOL)start
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,battery.address,7,3,start,0,0};
    //CRC校验
    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:7];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
    
}
- (void)readReferenceValue:(BatteryGroup *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,battery.address,8,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
    //发送数据
    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
    
}
- (void)updateReferenceValue:(BatteryGroup *)battery
{
    GCDAsyncSocket *sock = battery.socket;
    //socket确保连接
    if (![sock isConnected]) {
        NSError *err = nil;
        [sock connectToHost:defaultIP onPort:HostPort error:&err];
    }
    //数据封装
    Byte data[]={0xAA,battery.address,9,2,0,0};
    //CRC校验
    data[4] = [self getCRC16Code:data withNumber:4 fromIndex:0]%256;//CRC_L
    data[5] = [self getCRC16Code:data withNumber:4 fromIndex:0]/256;//CRC_H
    NSData *sendData = [NSData dataWithBytes:data length:6];
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
    BatteryGroup *batteryGroup = appDelegate.batteryGroup;
    //取功能码
    Byte *functionCodeBytes =(Byte *) [[data subdataWithRange:NSMakeRange(2, 1)] bytes];
    int functionCode = functionCodeBytes[0];
    switch (functionCode) {
        case 2: //预测数据
        {
            if (data.length<46) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 46)];
            //CRC校验
            if (![self isDataFitCRC16:validData]) {
                return;
            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 40)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            for (int i=0; i<4; i++) {
                Battery *battery = batteryGroup.batterys[i];
                int startIndex = i*10;
//                NSData *oneData = [dataContent subdataWithRange:NSMakeRange(startIndex, 12)];
//                Byte *oneByteData = (Byte *)[oneData bytes];
                battery.voltage = [NSNumber numberWithFloat: 0.001*(allData[startIndex]*256 + allData[startIndex+1])];
                battery.internalRes = [NSNumber numberWithFloat: 0.01*(allData[startIndex+2]*256 + allData[startIndex+3])];
                battery.maxCurrent = [NSNumber numberWithFloat: (allData[startIndex+4]*256 + allData[startIndex+5])];
                battery.healthState = [NSNumber numberWithFloat: (allData[startIndex+6] )];
                battery.currentEnergy = [NSNumber numberWithFloat: (allData[startIndex+7])];
                battery.capacity = [NSNumber numberWithFloat: 0.01*(allData[startIndex+8]*256 + allData[startIndex+9])];
            }
            if ([self.delegate respondsToSelector:@selector(managerDidReceiveData)]) {
                [self.delegate managerDidReceiveData];
            }
        }
            break;
        case 3: //充电数据
        {
            if (data.length<54) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 54)];
            //CRC校验
            if (![self isDataFitCRC16:validData]) {
                return;
            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 48)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            batteryGroup.acVoltage = [NSNumber numberWithFloat: 0.01*(allData[0]*256 + allData[1])];
            batteryGroup.acCurrent = [NSNumber numberWithFloat: 0.01*(allData[2]*256 + allData[3])];
            batteryGroup.power = [NSNumber numberWithFloat: 0.1*(allData[4]*256 + allData[5])];
            batteryGroup.powerFactor = [NSNumber numberWithFloat: 0.001*(allData[6]*256 + allData[7])];
            batteryGroup.powerConsumption = [NSNumber numberWithFloat: (((allData[8]*256 + allData[9])*65536+(allData[10]*256 + allData[11]))*0.0001)];
            
            batteryGroup.chargeVoltage = [NSNumber numberWithFloat: 0.001*(allData[44]*256 + allData[45])];
            batteryGroup.chargeCurrent = [NSNumber numberWithFloat: 0.01*(allData[46]*256 + allData[47])];
      
            
            for (int i=0; i<4; i++) {
                Battery *battery = batteryGroup.batterys[i];
                int startIndex = i*8+12;
        
                battery.state = allData[startIndex]*256 + allData[startIndex+1];
                battery.chargeVoltage = [NSNumber numberWithFloat: 0.001*(allData[startIndex+2]*256 + allData[startIndex+3])];
                battery.chargeCurrent = [NSNumber numberWithFloat: 0.01*(allData[startIndex+4]*256 + allData[startIndex+5])];
                battery.chargeEnergy = [NSNumber numberWithFloat: 0.01*(allData[startIndex+6]*256 + allData[startIndex+7])];
            }
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
            if (![self isDataFitCRC16:validData]) {
                return;
            }
            //将数据内容部分取出，转换成byte数组
            NSData *numberData = [validData subdataWithRange:NSMakeRange(4, 1)];
            Byte *numberByte = (Byte *)[numberData bytes];
            batteryGroup.batteryNumber = [NSNumber numberWithInt:numberByte[0]];
            
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(5, 9)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            batteryGroup.dischargeVoltage = [NSNumber numberWithFloat: 0.001*(allData[0]*256 + allData[1])];
            batteryGroup.dischargeCurrent = [NSNumber numberWithFloat: 0.01*(allData[2]*256 + allData[3])];
            batteryGroup.dischargeCapacity = [NSNumber numberWithFloat: 0.01*(allData[4]*256 + allData[5])];
            
            batteryGroup.hour = [NSNumber numberWithInt:allData[7]];
            batteryGroup.minute = [NSNumber numberWithInt:allData[8]];
            batteryGroup.second = [NSNumber numberWithInt:allData[9]];
            //            if ([self.delegate respondsToSelector:@selector(managerDidReceiveData)]) {
            //                [self.delegate managerDidReceiveData];
            //            }
            NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"HH:mm:ss"];
            NSString *time = [formatter stringFromDate:[NSDate date]];
            NSDictionary *dic = @{@"Voltage":batteryGroup.dischargeVoltage,@"Current":batteryGroup.dischargeCurrent,@"Capacity":batteryGroup.dischargeCapacity,@"Time":time};
            if ([self.delegate respondsToSelector:@selector(managerDidReceiveDischargeValue:)]) {
                [self.delegate managerDidReceiveDischargeValue:dic];
            }
            
        }
            break;
        case 5: //读取参数
        {
            if (data.length<20) {
                return;
            }
            //取出有效数据
            NSData *validData = [data subdataWithRange:NSMakeRange(0, 20)];
            //CRC校验
            //            if (![self isDataFitCRC16:validData]) {
            //                return;
            //            }
            //将数据内容部分取出，转换成byte数组
            NSData *dataContent = [validData subdataWithRange:NSMakeRange(4, 9)];
            Byte *allData = (Byte *)[dataContent bytes];
            
            batteryGroup.nominalCapacity = [NSNumber numberWithFloat: (allData[0]*256 + allData[1])];
            batteryGroup.singleVoltage = [NSNumber numberWithFloat:(allData[2]*256 + allData[3])];
            batteryGroup.cutoffVoltage = [NSNumber numberWithFloat:0.1*(allData[4]*256 + allData[5])];
            batteryGroup.batteryNumber = [NSNumber numberWithInt:allData[6]];
            batteryGroup.workState = [NSNumber numberWithInt:allData[7]];
            batteryGroup.isMaintain = [NSNumber numberWithInt:allData[8]];
//            batteryGroup.dischargeCurrentPara = [NSNumber numberWithFloat: 0.1*(allData[6]*256 + allData[7])];
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
        case 7: //自动校准
        {
            NSLog(@"%@",data);
        }
        case 8: //读取参考值
        {
            NSLog(@"%@",data);
            
            if (data.length<12) {
                return;
            }
            //取出有效数据
            Byte *allData = (Byte *)[data bytes];
            if (allData[3]==8) {
                NSNumber *soho = [NSNumber numberWithFloat:0.01*(allData[4]*256+allData[5])];
                NSNumber *voltage = [NSNumber numberWithFloat:0.01*(allData[6]*256+allData[7])];
                NSNumber *res = [NSNumber numberWithFloat:0.01*(allData[8]*256+allData[9])];
                NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HH:mm:ss"];
                NSString *time = [formatter stringFromDate:[NSDate date]];
                NSDictionary *dic = @{@"soho":soho,@"voltage":voltage,@"res":res,@"time":time};
                if ([self.delegate respondsToSelector:@selector(managerDidReceiveReferenceValue:)]) {
                    [self.delegate managerDidReceiveReferenceValue:dic];
                }
            }
            
        }
        case 9: //设定参考值
        {
            NSLog(@"%@",data);
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



//- (void)startChargeOfBattery:(Battery *)battery
//{
//    GCDAsyncSocket *sock = battery.socket;
//    //socket确保连接
//    if (![sock isConnected]) {
//        NSError *err = nil;
//        [sock connectToHost:defaultIP onPort:HostPort error:&err];
//    }
//    //数据封装
//    Byte data[]={0xAA,battery.address,3,3,1,0,0};
//    //CRC校验
//    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
//    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
//    NSData *sendData = [NSData dataWithBytes:data length:7];
//    //发送数据
//    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
//}
//- (void)stopChargeOfBattery:(Battery *)battery
//{
//    GCDAsyncSocket *sock = battery.socket;
//    //socket确保连接
//    if (![sock isConnected]) {
//        NSError *err = nil;
//        [sock connectToHost:defaultIP onPort:HostPort error:&err];
//    }
//    //数据封装
//    Byte data[]={0xAA,battery.address,3,3,0,0,0};
//    //CRC校验
//    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
//    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
//    NSData *sendData = [NSData dataWithBytes:data length:7];
//    //发送数据
//    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
//}

//- (void)startDischargeOfBattery:(Battery *)battery
//{
//    GCDAsyncSocket *sock = battery.socket;
//    //socket确保连接
//    if (![sock isConnected]) {
//        NSError *err = nil;
//        [sock connectToHost:defaultIP onPort:HostPort error:&err];
//    }
//    //数据封装
//    Byte data[]={0xAA,battery.address,4,3,1,0,0};
//    //CRC校验
//    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
//    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
//    NSData *sendData = [NSData dataWithBytes:data length:7];
//    //发送数据
//    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
//}
//- (void)stopDischargeOfBattery:(Battery *)battery
//{
//    GCDAsyncSocket *sock = battery.socket;
//    //socket确保连接
//    if (![sock isConnected]) {
//        NSError *err = nil;
//        [sock connectToHost:defaultIP onPort:HostPort error:&err];
//    }
//    //数据封装
//    Byte data[]={0xAA,battery.address,4,3,0,0,0};
//    //CRC校验
//    data[5] = [self getCRC16Code:data withNumber:5 fromIndex:0]%256;//CRC_L
//    data[6] = [self getCRC16Code:data withNumber:5 fromIndex:0]/256;//CRC_H
//    NSData *sendData = [NSData dataWithBytes:data length:7];
//    //发送数据
//    [sock writeData:sendData withTimeout:WriteTimeout tag:1];
//}

@end
