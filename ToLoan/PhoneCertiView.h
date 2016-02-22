//
//  PhoneCertiView.h
//  ToLoan
//
//  Created by jway on 15-4-27.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "certiProtocol.h"
@interface PhoneCertiView : UIViewController<UITextFieldDelegate>
//已认证view

@property (weak, nonatomic) IBOutlet UIView *hasCertiCiew;

//认证号码
@property (weak, nonatomic) IBOutlet UILabel *certiNum;

//手机号背景图
@property (weak, nonatomic) IBOutlet UIView *phoneBgView;

//待认证电话号码
@property (weak, nonatomic) IBOutlet UITextField *telPhone;
//验证码
@property (weak, nonatomic) IBOutlet UITextField *randomNum;

//获取验证码
- (IBAction)getRandom:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *getRandom;

//用来存放手机认证信息
@property(nonatomic,strong) NSDictionary*certi_dic;
//定义一个代理引用
@property(nonatomic,strong) id<certiProtocol>delegate;

//返回操作
- (IBAction)back:(id)sender;

//下一步操作
- (IBAction)nextStep:(id)sender;

@end
