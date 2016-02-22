//
//  itemDetailView.h
//  ToLoan
//
//  Created by jway on 15-4-22.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface itemDetailView : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

//项目详情表
@property (weak, nonatomic) IBOutlet UITableView *detailTable;

//“下一步”按钮
@property (weak, nonatomic) IBOutlet UIButton *nextStep;

- (IBAction)nextStep:(id)sender;

//定义一个字典类型数据，用来获取需要显示的数据
@property(nonatomic,strong) NSDictionary*get_dic;

//返回操作

- (IBAction)back:(id)sender;

//定义一个字符串，用来接受项目pid
@property(nonatomic,strong)NSString*itempid;

@end
