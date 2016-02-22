//
//  FinishbankCertiView.h
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FinishbankCertiView : UIViewController


//输入金额背景图
@property (weak, nonatomic) IBOutlet UIView *numBg;

//输入的金额
@property (weak, nonatomic) IBOutlet UITextField *money_num;

//认证
- (IBAction)certificate:(id)sender;

//解除绑定按钮

@property (weak, nonatomic) IBOutlet UIButton *moveBind;

- (IBAction)moveBind:(id)sender;

//返回操作
- (IBAction)back:(id)sender;

//存储银行卡号
@property(nonatomic,strong) NSString*cardID;

@end
