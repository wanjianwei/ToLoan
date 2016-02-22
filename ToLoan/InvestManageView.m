//
//  InvestManageView.m
//  ToLoan
//
//  Created by jway on 15-4-24.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "InvestManageView.h"
#import "AppDelegate.h"
#import "CustomCell.h"
#import "BasicInfoView.h"
@interface InvestManageView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    
    //定义一个页码，用于记录服务器返回的记录页码数
    int flag;
    //定义一个故事版引用
    UIStoryboard*main;
    //定义一个定时器
    NSTimer*timer;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView;
    
}

@end

@implementation InvestManageView

- (void)viewDidLoad {
    [super viewDidLoad];
    //指定代理
    self.investList.dataSource=self;
    self.investList.delegate=self;
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    //实例化故事版引用
    main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //在此处向服务器请求数据--先构造请求数据
    //将页码设置为1
    flag=1;
    //定义一个活动指示器
   activityView=[[UIActivityIndicatorView alloc] init];
   activityView.color=[UIColor blackColor];
   activityView.frame=CGRectMake(self.investList.bounds.size.width/2-40, self.investList.bounds.size.height/2-40, 80, 80);
    //加载并滚动
    [self.investList addSubview:activityView];
    [activityView startAnimating];
    
    NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"count",[NSString stringWithFormat:@"%i",flag],@"pager",nil];
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investProjectList.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if (operation.responseData)
             {
                 NSArray*get_array=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 
                 //将服务器返回的值传入array_list中
                 self.array_list=[[NSMutableArray alloc] initWithArray:get_array];
                 
                 //falg表示页码数，要加1
                 flag++;
                 
                 //活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 
                 //要在此处重新加载表视图数据
                 [self.investList reloadData];
             }
         }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    //延时1秒在判断网络连接状况
    [self performSelector:@selector(judgeNet) withObject:nil afterDelay:1];
}

//待程序已经启动一段时间后判断网络连接状况
-(void)judgeNet
{
    if (app.Rea_manager.reachable==NO)
        
    {
        //提示用户，检查网络
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
        //再次定义一个定时器，程序一旦进入后台，定时器就关闭了检测网络
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestAgain) userInfo:nil repeats:YES];
    }
}

//再次向服务器请求数据
-(void)requestAgain
{
    if (app.Rea_manager.reachable==YES)
    {
        //加载活动指示器
        [self.investList addSubview:activityView];
        [activityView startAnimating];
        
        //开始请求数据
        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"count",[NSString stringWithFormat:@"%i",flag],@"pager",nil];
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investProjectList.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if (operation.responseData)
             {
                 NSArray*get_array=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 //将服务器返回的值传入array_list中
                 self.array_list=[[NSMutableArray alloc] initWithArray:get_array];
                 //falg表示页码数，要加1
                 flag++;
                 //活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 //要在此处重新加载表视图数据
                 [self.investList reloadData];
                 //再次请求数据成功，把定时器注销
                 [timer invalidate];
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // 如果记录个数对10取余数不为0，则说明全部记录已经返回，否则还有数据未返回
    if (self.array_list.count%10!=0)
        return self.array_list.count;
    else
        return self.array_list.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==self.array_list.count)
    {
        
        UITableViewCell*cell=[[UITableViewCell alloc] init];
        UIButton*bt=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        [bt setTitle:@"查看更多" forState:UIControlStateNormal];
        [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [bt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        bt.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [bt addTarget:self action:@selector(forMore) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:bt];
        return cell;
    }
    else
    {
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        // Configure the cell...
        cell.name.text=[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"pname"];
        
       
        
        //投资进度百分比
        cell.percent.text=[NSString stringWithFormat:@"%2.0f%%",[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"comp"] intValue]/(float)[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"ptotal"] intValue]*100];
        
       
        
        cell.money_num.text=[NSString stringWithFormat:@"%i",[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"minbuy"] intValue]];
        
      
        
        //投资期限的计算
        
        //取出截止时间减去起始时间就是限期
        int startTime=[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"startTime"] intValue];
        
        int endTime=[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"endTime"] intValue];
        
        cell.time.text=[NSString stringWithFormat:@"限期:%i天",(endTime-startTime)/86400];
        
        
        //该项目的回款方式
        cell.fanshi.text=[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"type"];
        
       
        
        //年化率
        cell.nianhualv.text=[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"interest"];
       
        
        //项目总金额
        cell.itemNum.text=[NSString stringWithFormat:@"%i",[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"ptotal"] intValue]];
        
       
        
        //项目可投金额 总金额-已投金额
        cell.ketouNum.text=[NSString stringWithFormat:@"%i",[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"ptotal"] intValue]-[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"comp"] intValue]];
        
        
       
        //该项目的状态
        cell.state.text=[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"state"];
        
       
        
        //筹资进度条--已投金额/总金额
        cell.progress.progress=[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"comp"] intValue]/(float)[[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"ptotal"] intValue];
        
            return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}


//指定“加载更多”按钮的高度与其他自定义cell不同
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==self.array_list.count)
        return 44;
    else
        return 247;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (app.Rea_manager.reachable==YES)
    {
        //点击某个投资项目，这跳转到其详细介绍部分
        BasicInfoView*infoView=[main instantiateViewControllerWithIdentifier:@"basicinfo"];
        infoView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        //将所点击的项目的id传给下一个视图，便于查询该项目的详细信息
        infoView.itempid=[[self.array_list objectAtIndex:indexPath.section] objectForKey:@"pid"];
        //呈现视图
        [self presentViewController:infoView animated:YES completion:nil];

    }
    else
    {
        //提示用户，检查网络状态
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
 
    }
    
}

//加载更多记录
-(void)forMore
{
    if (app.Rea_manager.reachable==YES)
    {
        //增加一个网络指示器
        [self.investList addSubview:activityView];
        [activityView startAnimating];
        
        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:@"10",@"count",[NSString stringWithFormat:@"%i",flag],@"pager",nil];
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investProjectList.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if (operation.responseData)
             {
                 //活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 
                 NSArray*get_array=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 
                 //将服务器返回的值传入array_list中
                 [self.array_list addObjectsFromArray:get_array];
                 //falg表示页码数，要加1
                 flag++;
                 //要在此处重新加载表视图数据
                 [self.investList reloadData];
                 
             }
         }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             //提示用户，请求出错
             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请求数据失败" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];
         }];
    }
    else
    {
        //提示用户，检查网络状态
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
