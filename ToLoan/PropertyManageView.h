//
//  PropertyManageView.h
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PropertyManageView : UIViewController<UITableViewDataSource,UITableViewDelegate>


//返回操作
- (IBAction)back:(id)sender;

//管理项表单
@property (weak, nonatomic) IBOutlet UITableView *manage_list;
@end
