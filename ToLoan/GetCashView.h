//
//  GetCashView.h
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetCashView : UIViewController

//背景图
@property (weak, nonatomic) IBOutlet UIView *bgView1;

@property (weak, nonatomic) IBOutlet UIView *bgView2;

//可用余额
@property (weak, nonatomic) IBOutlet UILabel *money;

//提现金额输入
@property (weak, nonatomic) IBOutlet UITextField *getMoney;

//剩余额度和超出的手续费
@property (weak, nonatomic) IBOutlet UILabel *asset_info;

//下一步按钮

@property (weak, nonatomic) IBOutlet UIButton *nextStep;
- (IBAction)nextStep:(id)sender;

//返回操作
- (IBAction)back:(id)sender;
@end
