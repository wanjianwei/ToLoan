//
//  PayCashView.h
//  ToLoan
//
//  Created by jway on 15-5-1.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayCashView : UIViewController

//背景图
@property (weak, nonatomic) IBOutlet UIView *bgView;

//输入支付密码
@property (weak, nonatomic) IBOutlet UITextField *password;

//确定支付
- (IBAction)confirm:(id)sender;

//返回操作
- (IBAction)back:(id)sender;

//定义一个变量用来接受上个视图传送过来的支付金额
@property(nonatomic,strong)NSString*money_num;

//定义一个标志，用来区别这是来自于“投资项目”还是“提现"
@property(nonatomic,strong)NSNumber*flag;

//定义一个字符串，用来存取项目pid
@property(nonatomic,strong)NSString*itempid;
@end
