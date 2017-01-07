//
//  BatteryService.m
//  蓄电池系统
//
//  Created by 张天 on 2016/12/14.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "BatteryService.h"
#import "AFNetworking.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "XMLDictionary.h"

#define NameSpace @"http://www.suntrans.net/"
#define WebServiceUrl @"http://61.235.65.160:8602//" //@"http://210.42.122.127:8080/"  //   @"http://192.168.1.8:8080/"
#define ResultKey @"result"

#define InquiryPackMethod @"Inquiry_Pack"

#define InquiryAttributeDescriptionMethod @"Inquiry_AttributeDescription"
#define InquiryPackRMethod @"Inquiry_Pack_R"
#define InquiryPackSMethod @"Inquiry_Sub_R"
#define InquiryPackHMethod @"Inquiry_Pack_H"
#define ErrorCode @"1000"
@interface BatteryService()<NSURLSessionDelegate>

@end


@implementation BatteryService

+ (BatteryService *)shareService
{
    static BatteryService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
    });
    return service;
}
#pragma mark -  外部接口实现
+ (NSArray *)inquiryPack
{
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:InquiryPackMethod paraArray:nil];
    //NewDataSet
    NSDictionary *firstLayer = [resultDic valueForKey:[resultDic.nodeKeys firstObject]];
    NSArray *array = [firstLayer arrayValueForKeyPath:[firstLayer.nodeKeys firstObject]];
    return array;
}
+ (NSArray *)inquiryAttributeDescription
{
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:InquiryAttributeDescriptionMethod paraArray:nil];
    //NewDataSet
    NSDictionary *firstLayer = [resultDic valueForKey:[resultDic.nodeKeys firstObject]];
    NSArray *array = [firstLayer arrayValueForKeyPath:[firstLayer.nodeKeys firstObject]];
    return array;
}
+ (NSDictionary *)inquiryPackRealDataWithAddr:(NSString *)addr
{
    NSDictionary *paraDic1 = [NSDictionary dictionaryWithObjectsAndKeys:addr,@"BID", nil];
    NSArray *paraArray = [NSArray arrayWithObjects:paraDic1, nil];
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:InquiryPackRMethod paraArray:paraArray];
    //NewDataSet
    NSDictionary *firstLayer = [resultDic valueForKey:[resultDic.nodeKeys firstObject]];
    NSDictionary *dic = [firstLayer dictionaryValueForKeyPath:[firstLayer.nodeKeys firstObject]];
    return dic;
}
+ (NSArray *)inquirySubRealDataWithAddr:(NSString *)addr
{
    NSDictionary *paraDic1 = [NSDictionary dictionaryWithObjectsAndKeys:addr,@"BID", nil];
    NSArray *paraArray = [NSArray arrayWithObjects:paraDic1, nil];
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:InquiryPackSMethod paraArray:paraArray];
    //NewDataSet
    NSDictionary *firstLayer = [resultDic valueForKey:[resultDic.nodeKeys firstObject]];
    NSArray *array = [firstLayer arrayValueForKeyPath:[firstLayer.nodeKeys firstObject]];
    return array;
}
+ (NSArray *)inquiryPackHisData:(NSArray *)paraArray
{
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:@"Inquiry_Pack_H" paraArray:paraArray];
    //NewDataSet
    NSDictionary *firstLayer = [resultDic valueForKey:[resultDic.nodeKeys firstObject]];
    NSArray *array = [firstLayer arrayValueForKeyPath:[firstLayer.nodeKeys firstObject]];
    return array;
}
+ (NSArray *)inquirySubHisData:(NSArray *)paraArray
{
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:@"Inquiry_Sub_H" paraArray:paraArray];
    //NewDataSet
    NSDictionary *firstLayer = [resultDic valueForKey:[resultDic.nodeKeys firstObject]];
    NSArray *array = [firstLayer arrayValueForKeyPath:[firstLayer.nodeKeys firstObject]];
    return array;
}
+ (NSString *)insertChargeOrderAddr:(NSUInteger)addr number:(int)number isStart:(BOOL)isStart
{

    NSString *hexString = [[BatteryService shareService] ToHex:addr];
    if (addr<16) {
        hexString = [@"0" stringByAppendingString:hexString];
    }
    NSDictionary *paraDic1 = [NSDictionary dictionaryWithObjectsAndKeys:hexString,@"BAddr", nil];
    //数据封装
//    Byte data[]={0xAA,0,3,4,number,isStart};
//    NSData *sendData = [NSData dataWithBytes:data length:6];
//    NSString *sendString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",sendString);
    NSString *sendString = [NSString stringWithFormat:@"aa0%lu03040%d0%d",(unsigned long)addr,number+1,isStart];
    NSDictionary *paraDic2 = [NSDictionary dictionaryWithObjectsAndKeys:sendString,@"Command", nil];
    
    NSArray *paraArray = [NSArray arrayWithObjects:paraDic1,paraDic2,nil];
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:@"Insert_Order" paraArray:paraArray];
    //NewDataSet
    if (resultDic == nil) {
        return ErrorCode;
    }
    return [resultDic valueForKey:ResultKey];
}
+ (NSString *)insertDisChargeOrderAddr:(NSUInteger)addr number:(int)number isStart:(BOOL)isStart
{
    NSString *hexString = [[BatteryService shareService] ToHex:addr];
    if (addr<16) {
        hexString = [@"0" stringByAppendingString:hexString];
    }
    NSDictionary *paraDic1 = [NSDictionary dictionaryWithObjectsAndKeys:hexString,@"BAddr", nil];
    //数据封装
    //    Byte data[]={0xAA,0,3,4,number,isStart};
    //    NSData *sendData = [NSData dataWithBytes:data length:6];
    //    NSString *sendString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //    NSLog(@"%@",sendString);
    NSString *sendString = [NSString stringWithFormat:@"aa0%lu04040%d0%d",(unsigned long)addr,number,isStart];
    NSDictionary *paraDic2 = [NSDictionary dictionaryWithObjectsAndKeys:sendString,@"Command", nil];
    
    NSArray *paraArray = [NSArray arrayWithObjects:paraDic1,paraDic2,nil];
    NSDictionary *resultDic = [BatteryService webServiceWithMethod:@"Insert_Order" paraArray:paraArray];
    //NewDataSet
    if (resultDic == nil) {
        return ErrorCode;
    }
    return [resultDic valueForKey:ResultKey];
}
- (NSString *)ToHex:(uint16_t)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}
#pragma mark - 中间调用后面方法返回结果给前面的接口
+ (NSDictionary *)webServiceWithMethod:(NSString *)methodName paraArray:(NSArray *)paraArray
{
    BatteryService *service = [BatteryService shareService];
    NSString *soapMsg = [service soapMessageWithMethod:methodName paraArray:paraArray];
    //    NSLog(@"%@",[NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]]);
    NSDictionary *dic = [service getSyncRequestWithMethodName:methodName soapMessage:soapMsg];
    return dic;
}
#pragma mark - 消息封装
- (NSString *)soapMessageWithMethod:(NSString *)methodName paraArray:(NSArray *)paraArray
{
    //生成soapBody
    NSMutableString *soapBody = [NSMutableString stringWithFormat:@"<%@ xmlns=\"%@\">\n",methodName,NameSpace];
    //取出paraArray所有key及其值加进soapBody中 <LogIn xmlns=\"http://www.suntrans.net\">\n<UserName>string</UserName>\n<Password>string</Password>\n</LogIn>
    for (NSDictionary *dic in paraArray) {
        
        NSString *value = [[dic allValues] firstObject];
        NSString *key = [[dic allKeys] firstObject];
        
        [soapBody appendFormat:@"<%@>",key];
        [soapBody appendString:value];
        [soapBody appendFormat:@"</%@>\n",key];
    }
    [soapBody appendString:[NSString stringWithFormat:@"</%@>",methodName]];
    
    NSString *soapFormat = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n<soap:Body>\n%@\n</soap:Body>\n</soap:Envelope>";
    
    NSString *soapMsg = [NSString stringWithFormat:soapFormat,soapBody];
    return soapMsg;
}
#pragma mark - 消息请求
- (NSDictionary *)getSyncRequestWithMethodName:(NSString *)methodName soapMessage:(NSString *)soapMsg
{
    NSURL *url = [NSURL URLWithString:WebServiceUrl];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    //设置请求头
    [request addRequestHeader:@"Host" value:url.host];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
    [request addRequestHeader:@"Content-Length" value: [NSString stringWithFormat:@"%lu", (unsigned long)[soapMsg length]]];
    [request addRequestHeader:@"SOAPAction" value:[NSString stringWithFormat:@"\"%@%@\"",NameSpace,methodName]];
    
    //传soap信息
    [request appendPostData:[soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:5.0];//表示5秒请求超时
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    //    NSLog(@"%@",[[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding]);
    NSLog(@"开始请求");
    //设置同步
    [request startSynchronous];
    
    
    return [self parseRequest:request];
    
}
#pragma mark - 消息解析
- (NSDictionary *)parseRequest:(ASIHTTPRequest *)request
{
    NSLog(@"请求结束");
    int statusCode = [request responseStatusCode];
    
    //从soapAction中提取methodName
    NSString *soapAction = [[request requestHeaders] objectForKey:@"SOAPAction"];
    //去掉引号
    soapAction = [soapAction stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *arraySOAP =[soapAction componentsSeparatedByString:@"/"];
    NSString *methodName = [arraySOAP lastObject];
    
    //表示正常请求
    NSString *responseString = [request responseString];
    // 错误状态码处理
    if (statusCode != 200)
        return nil;
    //搜索methodName+Result标签下的xml
    NSError *error=nil;
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:responseString options:0 error:&error];
    if (error) {
        return nil;
    }
    GDataXMLElement* rootNode = [document rootElement];
    NSString *searchStr=[NSString stringWithFormat:@"%@Result",methodName];
    NSArray *result=[rootNode children];
    
    while ([result count]>0) {
        NSString *nodeName=[[result objectAtIndex:0] name];
        if ([nodeName isEqualToString: searchStr]) {
            result=[(GDataXMLNode *)[result objectAtIndex:0] children];
            break;
        }
        result=[(GDataXMLNode *)[result objectAtIndex:0] children];
    }
    
    //schema和xml
    NSDictionary *resultDic;
    if (result.count > 1)
    {
        NSString *resultString = [[result lastObject] XMLString];
        XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
        parser.attributesMode = XMLDictionaryAttributesModeDiscard;
        resultDic = [parser dictionaryWithString:resultString];
    }
    else
    {
        resultDic = [NSDictionary dictionaryWithObjectsAndKeys:[[result firstObject] stringValue],ResultKey, nil];
    }
    //        NSLog(@"%@",resultDic);
    return resultDic;
}

//- (void)requestWithMethod:(NSString *)method parameters:(NSString *)parameters
//{
//    NSString *URLString = @"https://www.suntrans.net:8017/WebService.asmx/%@";
//    URLString = [NSString stringWithFormat:URLString,method];
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
//
//    NSUInteger contentLength = request.HTTPBody.length;
//    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)contentLength] forHTTPHeaderField:@"Content-Length"];
//    [request addValue:@"www.suntrans.net" forHTTPHeaderField:@"Host"];
////    [request addValue:@"http://www.suntrans.net/Inquiry_Sites" forHTTPHeaderField:@"SOAPAction"];
////    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//
//    NSLog(@"%@",request.allHTTPHeaderFields);
//
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//
//
//
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, (NSXMLParser *)responseObject);
//        }
//    }];
//    [dataTask resume];
//}
//
@end
