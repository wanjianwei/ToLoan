//
//  BaoFooPayController.h
//  BaoFooPay
//
//  Created by baofoo on 15/3/29.
//  Copyright (c) 2015年 baofoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
//#import "Base64.h"
@protocol BaofooSdkDelegate <NSObject>

-(void)callBack:(NSString*)params;
@end
@interface BaoFooPayController : UIViewController<UIWebViewDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property(nonatomic,copy)NSString*PAY_BUSINESS;
@property(nonatomic,copy)NSString*PAY_TOKEN;
@property(nonatomic,assign,getter =isAuthed)BOOL authed;
@property(nonatomic,weak)id<BaofooSdkDelegate>delegate;
@end
