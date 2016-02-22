//
//  AccountAssetView.m
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "AccountAssetView.h"
#import "AppDelegate.h"
@interface AccountAssetView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    //定义一个字典，用来存储服务器返回数据
    NSDictionary*get_dic;
}

@end

@implementation AccountAssetView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 指定tableView的代理及其外观属性
    self.assetList.dataSource=self;
    self.assetList.delegate=self;
    self.assetList.layer.cornerRadius=6.0f;
    self.assetList.layer.borderColor=[[UIColor grayColor] CGColor];
    self.assetList.layer.borderWidth=1.0f;
    self.assetList.scrollEnabled=NO;
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, 110, 80, 80);
    
    [self.assetList addSubview:activityView];
    [activityView startAnimating];
    
    //请求数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getAccountInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        
        if (operation.responseData)
        {
            get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
            //表视图重新载入数据
            [self.assetList reloadData];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //活动指示器消失
         [activityView stopAnimating];
         [activityView removeFromSuperview];
         //提示用户，请求出错
         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"访问服务器出现错误" preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
         [alert addAction:action];
         [self presentViewController:alert animated:YES completion:nil];
    }];

}

- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
    if (indexPath.row==0)
    {
        cell.textLabel.text=@"账户资产概览";
        cell.backgroundColor=[UIColor grayColor];
    }
    else if (indexPath.row==1)
    {
        cell.textLabel.text=@"可用余额";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"balance"]];
    }
    else if (indexPath.row==2)
    {
        cell.textLabel.text=[NSString stringWithFormat:@"投资审核(%@笔)",[[get_dic objectForKey:@"invest"] objectForKey:@"count"]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[[get_dic objectForKey:@"invest"] objectForKey:@"total"]];
    }
    else if (indexPath.row==3)
    {
        cell.textLabel.text=@"提现中";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"withdraw"]];
    }
    else if (indexPath.row==4)
    {
        cell.textLabel.text=@"收益中";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"earning"]];
    }
    else
    {
        cell.textLabel.text=@"逾期中";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"overdue"]];
    }
    return cell;
}
@end
