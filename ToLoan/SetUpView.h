//
//  SetUpView.h
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUpView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//返回操作

- (IBAction)back:(id)sender;

//设置项表单

@property (weak, nonatomic) IBOutlet UITableView *setUp_list;

@end
