//
//  CardCertiView.h
//  ToLoan
//
//  Created by jway on 15-4-28.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "certiProtocol.h"
@interface CardCertiView : UIViewController<certiProtocol>


//返回操作
- (IBAction)back:(id)sender;

//开户名称

@property (weak, nonatomic) IBOutlet UILabel *nickname;

//银行logo
@property (weak, nonatomic) IBOutlet UIImageView *banklogo;

//选择银行按钮
- (IBAction)choseBank:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chosebank;

//输入银行卡号
@property (weak, nonatomic) IBOutlet UITextField *bankNum;

@property (weak, nonatomic) IBOutlet UIView *bgView;

//下一步
- (IBAction)nextStep:(id)sender;
@end
