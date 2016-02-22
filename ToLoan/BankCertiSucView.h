//
//  BankCertiSucView.h
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankCertiSucView : UIViewController

//返回操作
- (IBAction)back:(id)sender;

//背景图
@property (weak, nonatomic) IBOutlet UIView *bg;

//解除绑定

@property (weak, nonatomic) IBOutlet UIButton *moveBind;

- (IBAction)moveBind:(id)sender;

//银行卡号
@property (weak, nonatomic) IBOutlet UILabel *bankNum;

//定义一个数组用来存放银行卡号
@property(nonatomic,strong)NSString*cardID;

@end
