//
//  CustomCell3.h
//  ToLoan
//
//  Created by jway on 15-4-21.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell3 : UITableViewCell
//消息标题
@property (weak, nonatomic) IBOutlet UILabel *title;

//时间
@property (weak, nonatomic) IBOutlet UILabel *time;

//信息
@property (weak, nonatomic) IBOutlet UILabel *message;

@end
