//
//  RechargeView.m
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "RechargeView.h"
#import "AppDelegate.h"
@interface RechargeView ()
{
    //定义一个程序委托
    AppDelegate*app;
    
}

@end

@implementation RechargeView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理
    self.rec_List.dataSource=self;
    self.rec_List.delegate=self;
    //确定视图标题
    self.myTitle.text=self.title_view;
    
    //实例化程序委托
    app=[UIApplication sharedApplication].delegate;
    
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, self.rec_List.bounds.size.height/3, 80, 80);
    [self.rec_List addSubview:activityView];
    [activityView startAnimating];
    
    //向服务器请求数据
    if ([self.title_view isEqual:@"充值记录"])
    {
        //构造发送数据，请求数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getRechargeList.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            //活动指示器消失
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            //返回数据成功
            if (operation.responseData)
            {
                self.array_list=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                //表视图重载数据
                [self.rec_List reloadData];
                
                
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
    else
    {
        //构造发送数据，请求数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getCashList.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
            
             //返回数据成功
             self.array_list=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 //表视图重载数据
            [self.rec_List reloadData];
             
             
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array_list.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //定义cell的类型
    
    NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy];
    
    //配置cell
    cell.imageView.image=[UIImage imageNamed:@"20.png"];
    
    //单元格此处显示分情况
    if ([self.title_view isEqual:@"提现记录"])
    {
       cell.textLabel.text=[[self.array_list objectAtIndex:indexPath.row] objectForKey:@"state"];
    }
    else
        cell.textLabel.text=@"充值";
    
    //将时间戳转化为指定形式的时间显示
    NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate*date=[NSDate dateWithTimeIntervalSince1970:[[[self.array_list objectAtIndex:indexPath.row] objectForKey:@"time"] integerValue]];
    
    //转换为指定形式的时间显示
    cell.detailTextLabel.text=[formatter stringFromDate:date];
    
    //自定义一个label，显示充值金额
    UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-100, 0, 100, 44)];
    lab.textAlignment=NSTextAlignmentCenter;
    lab.text=[NSString stringWithFormat:@"%@元",[[self.array_list objectAtIndex:indexPath.row] objectForKey:@"money"]];
    [cell.contentView addSubview:lab];
    return cell;
}

@end
