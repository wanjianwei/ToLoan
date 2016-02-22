//
//  InvestManageView.h
//  ToLoan
//
//  Created by jway on 15-4-24.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvestManageView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//债权表单
@property (weak, nonatomic) IBOutlet UITableView *investList;

//定义一个可变数组，用来存放服务器返回数据
@property(nonatomic,strong)NSMutableArray*array_list;

@end
