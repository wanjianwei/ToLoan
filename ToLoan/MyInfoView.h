//
//  MyInfoView.h
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "certiProtocol.h"
@interface MyInfoView : UIViewController<UITableViewDataSource,UITableViewDelegate,certiProtocol>

//返回操作
- (IBAction)back:(id)sender;

//我的资料表单
@property (weak, nonatomic) IBOutlet UITableView *info_list;

@end
