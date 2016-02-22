//
//  MyNoticeView.h
//  ToLoan
//
//  Created by jway on 15-5-2.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyNoticeView : UIViewController<UITableViewDataSource,UITableViewDelegate>

//返回操作
- (IBAction)back:(id)sender;

//消息列表
@property (weak, nonatomic) IBOutlet UITableView *noticeList;
@end
