//
//  CustomCell.h
//  ToLoan
//
//  Created by jway on 15-4-19.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

//股票名称
@property (weak, nonatomic) IBOutlet UILabel *name;
//百分比
@property (weak, nonatomic) IBOutlet UILabel *percent;
//起投金额
@property (weak, nonatomic) IBOutlet UILabel *money_num;
//投资期限
@property (weak, nonatomic) IBOutlet UILabel *time;
//回款方式
@property (weak, nonatomic) IBOutlet UILabel *fanshi;
//预测年化率
@property (weak, nonatomic) IBOutlet UILabel *nianhualv;
//项目金额
@property (weak, nonatomic) IBOutlet UILabel *itemNum;
//可投金额
@property (weak, nonatomic) IBOutlet UILabel *ketouNum;
//当前状态
@property (weak, nonatomic) IBOutlet UILabel *state;

//进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progress;


@end
