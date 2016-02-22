//
//  CustomCell2.h
//  ToLoan
//
//  Created by jway on 15-4-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell2 : UITableViewCell


//债权名称
@property (weak, nonatomic) IBOutlet UILabel *name;

//项目金额
@property (weak, nonatomic) IBOutlet UILabel *itemNum;
//可投金额
@property (weak, nonatomic) IBOutlet UILabel *enableNum;
//当前状态
@property (weak, nonatomic) IBOutlet UILabel *state;

//投资时间

@property (weak, nonatomic) IBOutlet UILabel *time;


@end
