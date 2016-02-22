//
//  ForgetPWView.h
//  ToLoan
//
//  Created by jway on 15-4-29.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPWView : UIViewController<UITextFieldDelegate>

//手机号
@property (weak, nonatomic) IBOutlet UITextField *telPhone;
//验证码
@property (weak, nonatomic) IBOutlet UITextField *randomNum;
//新密码输入
@property (weak, nonatomic) IBOutlet UITextField *newpasswd;


//返回操作
- (IBAction)back:(id)sender;

//下一步操作
- (IBAction)nextStep:(id)sender;

//获得验证码
@property (weak, nonatomic) IBOutlet UIButton *getNum;
- (IBAction)getNum:(id)sender;
//背景图

@property (weak, nonatomic) IBOutlet UIView *phoneBg;
@property (weak, nonatomic) IBOutlet UIView *randonbg;

@property (weak, nonatomic) IBOutlet UIView *passwdbg;
@end
