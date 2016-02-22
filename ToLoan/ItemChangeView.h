//
//  ItemChangeView.h
//  ToLoan
//
//  Created by jway on 15-4-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemChangeView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//分段控件

@property (weak, nonatomic) IBOutlet UISegmentedControl *changeItem;
- (IBAction)chcangeItem:(id)sender;


//债权表单
@property (weak, nonatomic) IBOutlet UITableView *itemList;

//定义一个可变数组，用来接受服务器返回数据---可转让债权
@property(nonatomic,strong)NSMutableArray*array_list1;

//定义一个可变数组，用来接受服务器返回数据---转让中债权
@property(nonatomic,strong)NSMutableArray*array_list2;

//定义一个可变数组，用来接受服务器返回数据---转让记录
@property(nonatomic,strong)NSMutableArray*array_list3;


@end
