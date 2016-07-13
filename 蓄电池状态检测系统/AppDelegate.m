//
//  AppDelegate.m
//  蓄电池状态检测系统
//
//  Created by 张天 on 16/2/27.
//  Copyright © 2016年 张天. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
-(Battery *)battery
{
    if (_battery == nil) {
        _battery = [[Battery alloc] init];
    }
    return _battery;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"%@", NSLocalizedString(@"CFBundleDisplayName", Nil));
    //fake ip
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:80]; // 距离，是否能调到中间位置
    
    //    [[StreetlightManager shareManager] searchAllSwitchHX];
    
    [[UINavigationBar appearance] setBarTintColor:themeColor]; // 不使用半透明的话是原色 46-204-113 祖母绿
    [[UINavigationBar appearance] setTranslucent:NO];                       // 不使用半透明
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]]; // 导航栏标题颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]]; // 导航栏各种按钮颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; // 状态栏亮色
    
    [[UITabBar appearance] setTintColor:themeColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
