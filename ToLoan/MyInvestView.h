//
//  MyInvestView.h
//  ToLoan
//
//  Created by jway on 15-4-27.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyInvestView : UIViewController<UITableViewDelegate,UITableViewDataSource>

//改变信息模块
@property (weak, nonatomic) IBOutlet UISegmentedControl *changeState;

- (IBAction)changeState:(id)sender;
//我的项目
@property (weak, nonatomic) IBOutlet UITableView *itemList;

//返回操作
- (IBAction)back:(id)sender;

@end
