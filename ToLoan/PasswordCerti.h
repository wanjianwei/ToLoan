//
//  PasswordCerti.h
//  ToLoan
//
//  Created by jway on 15-4-29.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "certiProtocol.h"
@interface PasswordCerti : UIViewController<UITextFieldDelegate>

//标题
//该视图为修改密码与修改支付密码共用
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;

@property (weak, nonatomic) IBOutlet UITextField *pw1;

@property (weak, nonatomic) IBOutlet UITextField *pw2;

@property (weak, nonatomic) IBOutlet UITextField *pw3;

//确认操作
- (IBAction)confirm:(id)sender;

//返回操作

- (IBAction)back:(id)sender;

//定义一个字符串，用来保存当前视图的标题
@property(nonatomic,strong)NSString*viewTitle_temp;
//定义一个nsnumber用来存放是否已经设置支付密码
@property(nonatomic,strong)NSNumber*flag;

//设置一个代理引用
@property(nonatomic,strong) id<certiProtocol>delegate;
@end
