//
//  MyInvestView.m
//  ToLoan
//
//  Created by jway on 15-4-27.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "MyInvestView.h"
#import "AppDelegate.h"
#import "CustomCell2.h"

@interface MyInvestView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    //定义一个数组，用来存放“我的项目”
    NSArray*myItem_dic;
    //存放“我的收益”
    NSDictionary*myEarning;
    //基本信息
    NSDictionary*basic_info;
    
    //定义一个我的收益表单
    UITableView*earningList;
    
    //定义一个基本信息表单
    UITableView*basicInfo;
    
    //定义一个flag,用来判断当前点击的是哪个信息
    int flag;
    //增加一个flag1，判断当前是第几次点击"我的收益"
    int flag1;
    //增加一个flag2，判断当前是第几次点击“基本信息”
    int flag2;
    
    //定义一个定时器，用来检测网络连接状态
    NSTimer*timer;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView;
    
}

@end

@implementation MyInvestView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定协议代理
    self.itemList.dataSource=self;
    self.itemList.delegate=self;
    
    //配置“我的收益”表单
    earningList=[[UITableView alloc] initWithFrame:CGRectMake(20, 129, [UIScreen mainScreen].bounds.size.width-40, 356)];
    earningList.dataSource=self;
    earningList.delegate=self;
    //earning外观属性
    earningList.layer.cornerRadius=6.0f;
    earningList.scrollEnabled=NO;
    earningList.layer.borderColor=[[UIColor grayColor] CGColor];
    earningList.layer.borderWidth=1.0f;
    
    
    //配置基本信息表单
    basicInfo=[[UITableView alloc] initWithFrame:CGRectMake(20, 129, [UIScreen mainScreen].bounds.size.width-40, 88)];
    basicInfo.dataSource=self;
    basicInfo.delegate=self;
    //修饰表视图外观属性
    basicInfo.layer.cornerRadius=6.f;
    basicInfo.scrollEnabled=NO;
    basicInfo.layer.borderColor=[[UIColor grayColor] CGColor];
    basicInfo.layer.borderWidth=1.0f;
    
    if (self.changeState.selectedSegmentIndex==0)
        flag=0;
    else if (self.changeState.selectedSegmentIndex==1)
        flag=1;
    else
        flag=2;
    
    //第一次点击segment的“我的收益”，“基本信息”，这flag1为0；
    flag1=0;
    flag2=0;
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    //定义一个活动指示器
    activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
    
    [self.itemList addSubview:activityView];
    [activityView startAnimating];
    
    //向服务器请求投资项目信息
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInvestList.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        //请求数据成功
        if (operation.responseData)
        {
            myItem_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
            //重载数据
            [self.itemList reloadData];
        }
        else
        {
            //提示用户，我的项目为空
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前投资项目为0" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
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
    // Dispose of any resources that can be recreated.
}

//改变当前的状态
- (IBAction)changeState:(id)sender
{
    if ((self.changeState.selectedSegmentIndex==1)&&(flag!=1))
    {
        //--要先把其他表视图隐藏了
        self.itemList.hidden=YES;
        [basicInfo removeFromSuperview];
        //在设置flag的值，
        flag=1;
        //能后加载表示图
        [self.view addSubview:earningList];
            
        //如果是第一次点击，则构造发送数据,请求数据
        if (flag1==0)
        {
            //在此处判断是否连上网路
            if (app.Rea_manager.reachable==YES)
            {
                //增加活动指示器
                [self.view addSubview:activityView];
                [activityView startAnimating];
                
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInterestStatistics.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //请求成功去掉活动指示器
                     [activityView stopAnimating];
                     [activityView removeFromSuperview];
                     
                     myEarning=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     //表示图数据重新加载
                     [earningList reloadData];
                     
                     //同时把flag1设置为1
                     flag1=1;
                 }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     //请求成功去掉活动指示器
                     [activityView stopAnimating];
                     [activityView removeFromSuperview];
                 }];
            }
            else
            {
                //提示用户，请求出错
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                {
                    //在此处定义定时器检测网络连接状况
                    timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestAgain) userInfo:nil repeats:YES];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else
        {
            //如果不是第一次，就重载数据
            [earningList reloadData];
        }
        
    }
    //如果点击的是“基本信息”按钮
    else if ((self.changeState.selectedSegmentIndex==2)&&(flag!=2))
    {
        //--要先把其他表视图隐藏了
        self.itemList.hidden=YES;
        [earningList removeFromSuperview];
        //在设置flag的值，
        flag=2;
        //能后加载表示图
        [self.view addSubview:basicInfo];
        //如果是第一次点击该模块，则构造数据，发送服务器，请求返回数据
        if (flag2==0)
        {
            if (app.Rea_manager.reachable==YES)
            {
                //增加活动指示器
                [self.view addSubview:activityView];
                [activityView startAnimating];
                
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInterestInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //去掉活动指示器
                     [activityView stopAnimating];
                     [activityView removeFromSuperview];
                     
                     //请求数据成功
                     if (operation.responseData)
                     {
                         basic_info=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                         //表示图数据重新加载
                         [basicInfo reloadData];
                         
                         //同时把flag1设置为1
                         flag2=1;
                     }
                     
                 }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     //去掉活动指示器
                     [activityView stopAnimating];
                     [activityView removeFromSuperview];
                 }];
            }
            else
            {
                //提示用户，请求出错
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                {
                    //在此处定义定时器检测网络连接状况
                    timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestAgain) userInfo:nil repeats:YES];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
        else
        {
            //重载数据
            [basicInfo reloadData];
        }
    }
    //我的项目
    else
    {
        //把其他的tableView隐藏
        [basicInfo removeFromSuperview];
        [earningList removeFromSuperview];
        self.itemList.hidden=NO;
        //flag值再次设置为0
        flag=0;
    }
}

//再次请求数据
-(void)requestAgain
{
    if (app.Rea_manager.reachable==YES)
    {
        if (self.changeState.selectedSegmentIndex==1)
        {
            //增加活动指示器
            [self.view addSubview:activityView];
            [activityView startAnimating];
            [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInterestStatistics.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 //去掉活动指示器
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 
                 //定时器注销
                 [timer invalidate];
                 
                 myEarning=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 //表示图数据重新加载
                 [earningList reloadData];
                 //同时把flag1设置为1
                 flag1=1;
             }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 //去掉活动指示器
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
             }];

        }
        else if (self.changeState.selectedSegmentIndex==2)
        {
            //增加活动指示器
            [self.view addSubview:activityView];
            [activityView startAnimating];
            [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInterestInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 //去掉活动指示器
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 //定时器注销
                 [timer invalidate];
                 //请求数据成功
                 if (operation.responseData)
                 {
                     basic_info=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     //表示图数据重新加载
                     [basicInfo reloadData];
                     
                     //同时把flag1设置为1
                     flag2=1;
                 }
                 
             }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 //去掉活动指示器
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
             }];

        }
    }
}


#pragma Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (flag==0)
        return 1;
    else if (flag==1)
        return 6;
    else
        return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (flag==0)
       return myItem_dic.count;
    else if (flag1==1)
        return 1;
    else
        return 1;
}

//表足高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (flag==0)
       return 5;
    else
       return 0;
}

//单元格的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (flag==0)
    {
        return 161;
    }
    else if (flag==1)
    {
        if (indexPath.row==2||indexPath.row==3)
            return 90;
        else
            return 44;
        
    }
    else
        return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (flag==0)
    {
        CustomCell2*cell=[tableView dequeueReusableCellWithIdentifier:@"MyInvestCell"];
        cell.name.text=[[myItem_dic objectAtIndex:indexPath.section] objectForKey:@"pname"];
        cell.itemNum.text=[NSString stringWithFormat:@"%@元",[[myItem_dic objectAtIndex:indexPath.section] objectForKey:@"ptotal"]];
        cell.state.text=[[myItem_dic objectAtIndex:indexPath.section] objectForKey:@"state"];
        cell.enableNum.text=[NSString stringWithFormat:@"%@元",[[myItem_dic objectAtIndex:indexPath.section] objectForKey:@"invest"]];
        
        //设置日期格式
        NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        //将起息日转为NSDate形式
        NSDate*date1=[NSDate dateWithTimeIntervalSince1970:[[[myItem_dic objectAtIndex:indexPath.section] objectForKey:@"time"] integerValue]];
        cell.time.text=[formatter stringFromDate:date1];
        return cell;
    }
    else if (flag==1)
    {
        static NSString*identy=@"earnCell";
        UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"投资收益统计";
            cell.textLabel.textColor=[UIColor blackColor];
            cell.backgroundColor=[UIColor grayColor];
        }
        else if (indexPath.row==1)
        {
            cell.textLabel.text=[NSString stringWithFormat:@"投资审核中(%@笔)",[[myEarning objectForKey:@"check"] objectForKey:@"count"]];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[[myEarning objectForKey:@"check"] objectForKey:@"total"]];
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.textColor=[UIColor grayColor];
           
        }
        else if (indexPath.row==2)
        {
            //自定义label
            UILabel*lab1=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
            lab1.textAlignment=NSTextAlignmentRight;
            lab1.font=[UIFont boldSystemFontOfSize:14];
            lab1.text=@"收益中总额";
            lab1.textColor=[UIColor grayColor];
            [cell.contentView addSubview:lab1];
            //收益中总额
            UILabel*lab_1=[[UILabel alloc] initWithFrame:CGRectMake(earningList.frame.size.width-80, 0, 80, 30)];
            
            lab_1.text=[NSString stringWithFormat:@"%d元",[[[myEarning objectForKey:@"earn"] objectForKey:@"capital"] intValue]+[[[myEarning objectForKey:@"earn"] objectForKey:@"income"] intValue]];
            lab_1.font=[UIFont boldSystemFontOfSize:14];
            lab_1.textColor=[UIColor blueColor];
            lab_1.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:lab_1];
            
            //本金
            //自定义label
            UILabel*lab2=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 30)];
            lab2.textAlignment=NSTextAlignmentRight;
            lab2.textColor=[UIColor grayColor];
            lab2.font=[UIFont boldSystemFontOfSize:12];
            lab2.text=@"本金";
            [cell.contentView addSubview:lab2];
            //收益中总额
            UILabel*lab_2=[[UILabel alloc] initWithFrame:CGRectMake(earningList.frame.size.width-80, 30, 80, 30)];
            
            lab_2.text=[NSString stringWithFormat:@"%@元",[[myEarning objectForKey:@"earn"] objectForKey:@"capital"]];
            lab_2.font=[UIFont boldSystemFontOfSize:12];
            lab_2.textColor=[UIColor grayColor];
            lab_2.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:lab_2];
            
            //收益
            //自定义label
            UILabel*lab3=[[UILabel alloc] initWithFrame:CGRectMake(20, 60, 100, 30)];
            lab3.textAlignment=NSTextAlignmentRight;
            lab3.textColor=[UIColor grayColor];
            lab3.font=[UIFont boldSystemFontOfSize:12];
            lab3.text=@"收益";
            [cell.contentView addSubview:lab3];
            //收益中总额
            UILabel*lab_3=[[UILabel alloc] initWithFrame:CGRectMake(earningList.frame.size.width-80, 60, 80, 30)];
            
            lab_3.text=[NSString stringWithFormat:@"%@元",[[myEarning objectForKey:@"earn"] objectForKey:@"income"]];
            lab_3.font=[UIFont boldSystemFontOfSize:12];
            lab_3.textColor=[UIColor grayColor];
            lab_3.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:lab_3];
            
         
            
        }
        else if (indexPath.row==3)
        {
            //自定义label
            UILabel*lab1=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
            lab1.textAlignment=NSTextAlignmentRight;
            lab1.font=[UIFont boldSystemFontOfSize:14];
            lab1.text=@"已回款总额";
            lab1.textColor=[UIColor grayColor];
            [cell.contentView addSubview:lab1];
            //收益中总额
            UILabel*lab_1=[[UILabel alloc] initWithFrame:CGRectMake(earningList.frame.size.width-80, 0, 80, 30)];
            
            lab_1.text=[NSString stringWithFormat:@"%d元",[[[myEarning objectForKey:@"getMoney"] objectForKey:@"capital"] intValue]+[[[myEarning objectForKey:@"getMoney"] objectForKey:@"income"] intValue]];
            lab_1.font=[UIFont boldSystemFontOfSize:14];
            lab_1.textColor=[UIColor blueColor];
            lab_1.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:lab_1];
            
            //本金
            //自定义label
            UILabel*lab2=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 30)];
            lab2.textAlignment=NSTextAlignmentRight;
            lab2.textColor=[UIColor grayColor];
            lab2.font=[UIFont boldSystemFontOfSize:12];
            lab2.text=@"本金";
            [cell.contentView addSubview:lab2];
            //收益中总额
            UILabel*lab_2=[[UILabel alloc] initWithFrame:CGRectMake(earningList.frame.size.width-80, 30, 80, 30)];
            
            lab_2.text=[NSString stringWithFormat:@"%@元",[[myEarning objectForKey:@"getMoney"] objectForKey:@"capital"]];
            lab_2.font=[UIFont boldSystemFontOfSize:12];
            lab_2.textColor=[UIColor grayColor];
            lab_2.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:lab_2];
            
            //收益
            //自定义label
            UILabel*lab3=[[UILabel alloc] initWithFrame:CGRectMake(20, 60, 100, 30)];
            lab3.textAlignment=NSTextAlignmentRight;
            lab3.textColor=[UIColor grayColor];
            lab3.font=[UIFont boldSystemFontOfSize:12];
            lab3.text=@"收益";
            [cell.contentView addSubview:lab3];
            //收益中总额
            UILabel*lab_3=[[UILabel alloc] initWithFrame:CGRectMake(earningList.frame.size.width-80, 60, 80, 30)];
            
            lab_3.text=[NSString stringWithFormat:@"%@元",[[myEarning objectForKey:@"getMoney"] objectForKey:@"income"]];
            lab_3.font=[UIFont boldSystemFontOfSize:12];
            lab_3.textColor=[UIColor grayColor];
            lab_3.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:lab_3];

          
        }
        else if (indexPath.row==4)
        {
            cell.textLabel.text=@"风险保证金";
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[myEarning objectForKey:@"deposit"]];
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.textColor=[UIColor grayColor];
            
        }
        else
        {
            cell.textLabel.text=@"逾期中总额";
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[myEarning objectForKey:@"overdue"]];
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.textColor=[UIColor grayColor];
          
        }
        return cell;
    }
    else
    {
        static NSString*identy=@"basicCell";
        UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"累计收益";
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[[basic_info objectForKey:@"income"] objectForKey:@"total"]];
            cell.detailTextLabel.textColor=[UIColor orangeColor];
        }
        else
        {
            cell.textLabel.text=@"待回款总额";
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[basic_info objectForKey:@"stay"]];
        }
        return cell;
    }
    
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
