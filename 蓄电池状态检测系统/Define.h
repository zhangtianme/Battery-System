//
//  Define.h
//  HomeManager
//
//  Created by 张天 on 15/3/21.
//  Copyright (c) 2015年 张天. All rights reserved.
//

#ifndef HomeManager_Define_h
#define HomeManager_Define_h



#import "AppDelegate.h"
#import "MBProgressHUD+MJ.h"
#import "MJRefresh.h"
#import "GCDAsyncSocket.h"
#import "IQKeyboardManager.h"
#import "BatteryManager.h"
#import "AppDelegate.h"
#import "Battery.h"
#import "BatteryGroup.h"
#import "UIGlossyButton.h"
#import "UIView+Extension.h"
#import "MemDataManager.h"
#import "BatteryService.h"

#define color(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBA(rgbValue,alphaa) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaa]


#define themeColor RGB(0x50E3C2)
#define matchColor RGB(0xCBF7ED)

#define ScreenWidth  self.view.frame.size.width
#define ScreenHeight   self.view.frame.size.height


#endif
