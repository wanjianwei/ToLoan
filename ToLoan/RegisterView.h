//
//  RegisterView.h
//  ToLoan
//
//  Created by jway on 15-4-22.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterView : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

//返回操作
- (IBAction)back:(id)sender;

//注册信息填写部分
@property (weak, nonatomic) IBOutlet UITableView *registerPart;
@end
