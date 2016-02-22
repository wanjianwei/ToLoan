//
//  PropertyManageView.m
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "PropertyManageView.h"
#import "AppDelegate.h"
#import "RechargeView.h"
#import "AccountAssetView.h"

#import "earningView.h"

@interface PropertyManageView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    
    //定义一个字符串，用来存储余额
    NSString*money_num;
    
}

@end

@implementation PropertyManageView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理,并设置表视图属性
    self.manage_list.dataSource=self;
    self.manage_list.delegate=self;
    self.manage_list.backgroundColor=[UIColor clearColor];
    self.manage_list.scrollEnabled=NO;
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    if (app.Rea_manager.reachable==YES)
    {
        //定义一个活动指示器
        UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] init];
        activityView.color=[UIColor blackColor];
        activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, self.manage_list.bounds.size.height/3, 80, 80);
        [self.view addSubview:activityView];
        [activityView startAnimating];
        
        //表视图的可交互性设置为NO；
        self.manage_list.userInteractionEnabled=NO;
        
        //获取可用余额
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                       {
                           //获取可用余额
                           [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getAccountInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
                            {
                                //活动指示器消失
                                [activityView stopAnimating];
                                [activityView removeFromSuperview];
                                //恢复可交互性
                                self.manage_list.userInteractionEnabled=YES;
                                
                                if (operation.responseData!=nil)
                                {
                                    //获取数据
                                    NSDictionary*get_dic1=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                                    
                                    //在主线程上更新数据
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       money_num=[NSString stringWithFormat:@"%@元",[get_dic1 objectForKey:@"balance"]];
                                                       //重新加载表数据
                                                       [self.manage_list reloadData];
                                                   });
                                }
                            }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
                            {
                                //活动指示器消失
                                [activityView stopAnimating];
                                [activityView removeFromSuperview];
                                //恢复可交互性
                                self.manage_list.userInteractionEnabled=YES;
                            }];
                           
                       });

    }
    else
    {
        //提示网络连接断开，无法获取“可用余额”
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络未连接，获取可用余额失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
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
    return  3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return 1;
    else if (section==1)
        return 2;
    else
        return 2;
    
}

//配置单元格
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
    
    if (indexPath.section==0)
    {
        cell.imageView.image=[UIImage imageNamed:@"15.png"];
        cell.textLabel.text=@"可用余额";
        
        //可用余额的数值来源于服务器,如果获取成功，则显示
        if (money_num!=nil)
            cell.detailTextLabel.text=money_num;
        else
            cell.detailTextLabel.text=@"0.0元";
        cell.detailTextLabel.textColor=[UIColor redColor];
        
    }
    else if (indexPath.section==1)
    {
        if (indexPath.row==0)
        {
            cell.imageView.image=[UIImage imageNamed:@"14.png"];
            cell.textLabel.text=@"充值记录";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.imageView.image=[UIImage imageNamed:@"16.png"];
            cell.textLabel.text=@"提现记录";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        if (indexPath.row==0)
        {
            cell.imageView.image=[UIImage imageNamed:@"12.png"];
            cell.textLabel.text=@"账户记录";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;

        }
        else
        {
            cell.imageView.image=[UIImage imageNamed:@"13.png"];
            cell.textLabel.text=@"投资收益";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (app.Rea_manager.reachable==YES)
    {
        if (indexPath.section==1)
        {
            //向服务器请求数据，“充值记录”和“提现记录”可以共用一个模板
            //////////此处省略
            UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RechargeView*view=[main instantiateViewControllerWithIdentifier:@"recharge"];
            view.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            //确定下一界面的标题
            view.title_view=(indexPath.row==0)?@"充值记录":@"提现记录";
            
            [self presentViewController:view animated:YES completion:nil];
            
        }
        else if(indexPath.section==2)
        {
            if (indexPath.row==0)
            {
                //向服务器请求数据--此处省略
                UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AccountAssetView*accoutView=[main instantiateViewControllerWithIdentifier:@"account"];
                accoutView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                [self presentViewController:accoutView animated:YES completion:nil];
                
            }
            else
            {
                //向服务器请求数据--此处省略
                UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                earningView*earningView=[main instantiateViewControllerWithIdentifier:@"earning"];
                earningView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                /////////传值--此处省略
                [self presentViewController:earningView animated:YES completion:nil];
                
            }
        }

    }
    else
    {
        //提示用户打开网络
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
