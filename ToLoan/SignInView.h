//
//  SignInView.h
//  ToLoan
//
//  Created by jway on 15-4-22.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInView : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

//注册按钮
- (IBAction)register_now:(id)sender;

//返回操作
- (IBAction)back:(id)sender;

//头像


@property (weak, nonatomic) IBOutlet UIImageView *portrait;

//登录信息填写框
@property (weak, nonatomic) IBOutlet UITableView *infoPart;

//登录按钮

@property (weak, nonatomic) IBOutlet UIButton *signIn;
- (IBAction)signIn:(id)sender;

//忘记密码

- (IBAction)forget_pw:(id)sender;

@end
