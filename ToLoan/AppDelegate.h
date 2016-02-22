//
//  AppDelegate.h
//  ToLoan
//
//  Created by jway on 15-4-19.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetWorking.h"
#import "AFNetworkActivityIndicatorManager.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//定义一个网络连接管理器
@property(nonatomic,strong)AFHTTPRequestOperationManager * manager;
//定义一个检测网络连接状态的管理器
@property(nonatomic,strong)AFNetworkReachabilityManager*Rea_manager;
@end

