//
//  earningView.h
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface earningView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//返回操作
- (IBAction)back:(id)sender;

//收益表单
@property (weak, nonatomic) IBOutlet UITableView *earningList;



@end
