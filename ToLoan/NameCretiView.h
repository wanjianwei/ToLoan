//
//  NameCretiView.h
//  ToLoan
//
//  Created by jway on 15-4-28.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "certiProtocol.h"

@interface NameCretiView : UIViewController<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIView *nameView;

@property (weak, nonatomic) IBOutlet UIView *idView;

//用户真实姓名
@property (weak, nonatomic) IBOutlet UITextField *nickname;

//用户身份证号
@property (weak, nonatomic) IBOutlet UITextField *cretiID;

//下一步操作
- (IBAction)nextStep:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *nextStep;

//定义一个字典类型数据，用来存储上个模块传送来的认证数据
@property(nonatomic,strong)NSDictionary*certi_dic;

//已经进行实名认证的展示
@property (weak, nonatomic) IBOutlet UIView *hasCertiView;

@property (weak, nonatomic) IBOutlet UILabel *idNum;

//返回操作
- (IBAction)back:(id)sender;

//定义一个代理引用
@property(nonatomic,strong) id<certiProtocol>delegate;

@end
