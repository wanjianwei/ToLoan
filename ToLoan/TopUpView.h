//
//  TopUpView.h
//  ToLoan
//
//  Created by jway on 15-5-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopUpView : UIViewController<UITextFieldDelegate>
//支付按钮

@property (weak, nonatomic) IBOutlet UIButton *payMoney;

- (IBAction)payMoney:(id)sender;
//输入金额框
@property (weak, nonatomic) IBOutlet UITextField *money;
//返回按钮
- (IBAction)back:(id)sender;

@end
