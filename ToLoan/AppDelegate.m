//
//  AppDelegate.m
//  ToLoan
//
//  Created by jway on 15-4-19.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemRecommendViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //初始化并设置网络热舞请求管理器
    self.manager=[AFHTTPRequestOperationManager manager];
    self.manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    //定义可以处理的响应的类型为“text/html”，否则会在failture中回调
   // _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //实例化网络状态管理器
    self.Rea_manager=[AFNetworkReachabilityManager sharedManager];
    //设置初始用户状态为未登录
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"userstate"];
    //初始化网络活动指示器
    [AFNetworkActivityIndicatorManager sharedManager].enabled=YES;
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 停止检测网络连接状态
    [self.Rea_manager stopMonitoring];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //开始检测网络连接状态
    [self.Rea_manager startMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
