//
//  RechargeView.h
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RechargeView : UIViewController<UITableViewDelegate,UITableViewDataSource>

//返回操作
- (IBAction)back:(id)sender;

//充值记录表单
@property (weak, nonatomic) IBOutlet UITableView *rec_List;

//定义一个数组，用来接受服务器返回的数据
@property(nonatomic,strong)NSArray*array_list;

//视图的标题
@property (weak, nonatomic) IBOutlet UILabel *myTitle;

//定义一个字符串，用来存放上一视图传送来的标题
@property(strong,nonatomic)NSString*title_view;

@end
