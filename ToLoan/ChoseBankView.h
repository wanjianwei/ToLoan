//
//  ChoseBankView.h
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "certiProtocol.h"
@interface ChoseBankView : UIViewController<UITableViewDelegate,UITableViewDataSource>

//银行列表
@property (weak, nonatomic) IBOutlet UITableView *bankList;

//定义一个委托引用
@property(nonatomic,strong) id<certiProtocol>delegate;

@end
