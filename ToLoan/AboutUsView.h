//
//  AboutUsView.h
//  ToLoan
//
//  Created by jway on 15-4-29.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//返回操作
- (IBAction)back:(id)sender;

//公司简介
@property (weak, nonatomic) IBOutlet UITableView *aboutus;

@end
