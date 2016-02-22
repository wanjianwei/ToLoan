//
//  BasicInfoView.h
//  ToLoan
//
//  Created by jway on 15-4-21.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicInfoView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//“我要投资”按钮
@property (weak, nonatomic) IBOutlet UIButton *touzhi;

- (IBAction)touzhi:(id)sender;
//剩余时间
@property (weak, nonatomic) IBOutlet UILabel *restTime;

//进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progress_view;

//返回操作
- (IBAction)back:(id)sender;

//界面装载view
@property (weak, nonatomic) IBOutlet UIView *bgView;

//界面label控件

//项目金额
@property (weak, nonatomic) IBOutlet UILabel *ptotal;

//项目起投金额
@property (weak, nonatomic) IBOutlet UILabel *minbuy;

//项目可投金额
@property (weak, nonatomic) IBOutlet UILabel *prest;

//项目投资期限
@property (weak, nonatomic) IBOutlet UILabel *time;

//项目起息日
@property (weak, nonatomic) IBOutlet UILabel *gitime;
//项目的回款日
@property (weak, nonatomic) IBOutlet UILabel *capitalTime;
//回款方式
@property (weak, nonatomic) IBOutlet UILabel *type;
//产品类型
@property (weak, nonatomic) IBOutlet UILabel *ptype;

//已投金额所占百分比
@property (weak, nonatomic) IBOutlet UILabel *percent;

//项目的年化率
@property (weak, nonatomic) IBOutlet UILabel *interest;

//项目的名称
@property (weak, nonatomic) IBOutlet UILabel *pname;


//分段控件，判断需加载的是哪个控件
@property (weak, nonatomic) IBOutlet UISegmentedControl *choseFounc;

- (IBAction)choseFounc:(id)sender;


//定义一个字符串，用来存储项目id；
@property(nonatomic,strong)NSString*itempid;

@end
