//
//  ItemRecommendViewController.h
//  ToLoan
//
//  Created by jway on 15-4-19.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMCircularProgressView.h"
@interface ItemRecommendViewController : UIViewController
//展示图片
@property (weak, nonatomic) IBOutlet UIImageView *DisImage;

//利率进度圆弧
@property(nonatomic,strong) IBOutlet MMCircularProgressView *ProgImage;
//“立即投资按钮”
@property (weak, nonatomic) IBOutlet UIButton *cathectic;

- (IBAction)cathectic:(id)sender;

//
//年化率
@property (weak, nonatomic) IBOutlet UILabel *interest;

//为客户赚取的金额
@property (weak, nonatomic) IBOutlet UILabel *make_total_money;

//购买的人数
@property (weak, nonatomic) IBOutlet UILabel *buycount;

//当前筹资的比例
@property (weak, nonatomic) IBOutlet UILabel *percent;

@end
