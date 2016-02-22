//
//  CheckCardInfoView.h
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckCardInfoView : UIViewController

//开户姓名
@property (weak, nonatomic) IBOutlet UILabel *username;

//开户银行
@property (weak, nonatomic) IBOutlet UILabel *bankName;

//银行卡号
@property (weak, nonatomic) IBOutlet UILabel *bankNum;

//银行名称
@property(nonatomic,strong) NSString*bakName_temp;

//银行卡号
@property(nonatomic,strong) NSString*cardID;

//银行id
@property(nonatomic,strong) NSNumber*bankid;

//下一步操作
- (IBAction)nextStep:(id)sender;

//返回操作
- (IBAction)back:(id)sender;

@end
