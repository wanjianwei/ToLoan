//
//  BasicInfoView.m
//  ToLoan
//
//  Created by jway on 15-4-21.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "BasicInfoView.h"
#import "AppDelegate.h"
#import "itemDetailView.h"
#import "SignInView.h"
#import "CustomCell3.h"
@interface BasicInfoView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    //定义一个标志用来判断分段控件响应哪个segment
    int flag;
    //定义一个int，来存放倒计时的时间戳
    int timeRest;
    //定义一个定时器，用来执行了倒计时
    NSTimer*timer;
    //定义一个字典，用来存储服务器返回的信息
    NSDictionary*return_dic;
    
    //定义两个表视图
    //申购记录
    UITableView*recordList;
    //投资须知
    UITableView*toKnow;
    //定义标志，用来判断请求“申购记录”的页码
    int flag1;
    //定义一个可变数组，用来存放申购记录
    NSMutableArray*array_List;
    
    //定义第二个计时器，用来检测网络连接状态
    NSTimer*timer1;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView;
   
}

@end

@implementation BasicInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //先构造两个表视图
    recordList=[[UITableView alloc] initWithFrame:CGRectMake(0, 126, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-126)];
    recordList.delegate=self;
    recordList.dataSource=self;
    

    
    toKnow=[[UITableView alloc] initWithFrame:CGRectMake(15, 130, [UIScreen mainScreen].bounds.size.width-30, 164)];
    toKnow.dataSource=self;
    toKnow.delegate=self;
    //投资须知列表不能移动
    toKnow.scrollEnabled=NO;
    //修饰投资须知表格的外观
    toKnow.layer.cornerRadius=5.0f;
    toKnow.layer.borderColor=[[UIColor grayColor] CGColor];
    toKnow.layer.borderWidth=1.0f;
    
    //每次向服务器请求10条记录，页码从0开始
    flag1=0;
    
    //初始化可变数组
    array_List=[[NSMutableArray alloc] init];
    
    //按钮外观属性
    self.touzhi.layer.cornerRadius=4.0f;
    //设置flag的初始值
    if (self.choseFounc.selectedSegmentIndex==0)
        flag=0;
    else if (self.choseFounc.selectedSegmentIndex==1)
        flag=1;
    else
        flag=2;
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    //定义一个活动指示器
    activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
    //加载活动指示器
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    //向服务器获取请求数据---请求的是项目的详细信息
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/projectDetail.do" parameters:[NSDictionary dictionaryWithObject:self.itempid forKey:@"pid"] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (operation.responseData)
         {
             //取出数据
             return_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
             
             
             NSLog(@"state=%@",[return_dic objectForKey:@"state"]);
             
             //填充数据
             //年化率
             self.interest.text=[return_dic objectForKey:@"interest"];
             //项目名称
             self.pname.text=[return_dic objectForKey:@"pname"];
             //项目总金额
             self.ptotal.text=[NSString stringWithFormat:@"%@元",[return_dic  objectForKey:@"ptotal"]];
             //起投金额
             self.minbuy.text=[NSString stringWithFormat:@"%@元",[return_dic objectForKey:@"minbuy"]];
             //可投金额--总金额减去已投金额
             self.prest.text=[NSString stringWithFormat:@"%i元",[[return_dic objectForKey:@"ptotal"] intValue]-[[return_dic objectForKey:@"comp"] intValue]];
             
             //投资期限 开始时间戳减去结束时间戳
             int startTime=[[return_dic objectForKey:@"startTime"] intValue];
             int endTime=[[return_dic objectForKey:@"endTime"] intValue];
             self.time.text=[NSString stringWithFormat:@"%2.1f天",(endTime-startTime)/86400.0];
             //设置日期格式
             NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"yyyy-MM-dd"];
             
             //将起息日转为NSDate形式
             NSDate*date1=[NSDate dateWithTimeIntervalSince1970:[[return_dic objectForKey:@"gitime"] integerValue]];
             //将回款日转为NSDate形式
             NSDate*date2=[NSDate dateWithTimeIntervalSince1970:[[return_dic objectForKey:@"capitalTime"] integerValue]];
             
             self.gitime.text=[formatter stringFromDate:date1];
             
             self.capitalTime.text=[formatter stringFromDate:date2];
             
             //回款方式
             self.type.text=[return_dic objectForKey:@"type"];
             //产品类型
             self.ptype.text=[return_dic objectForKey:@"pType"];
             //已投金额所占百分比
             self.percent.text=[NSString stringWithFormat:@"%4.2f%%",[[return_dic objectForKey:@"comp"] intValue]/(float)[[return_dic  objectForKey:@"ptotal"] intValue]*100];
             //进度条进度
             self.progress_view.progress=[[return_dic objectForKey:@"comp"] intValue]/(float)[[return_dic  objectForKey:@"ptotal"] intValue];
            
             //如果招标已经结束，这“我要投资”按钮不能响应事件；倒计时label用来显示招标结束提示
             if ([[return_dic objectForKey:@"state"] isEqual:@"已结束"]||[[return_dic objectForKey:@"state"] isEqual:@"收益中"])
             {
                 self.touzhi.backgroundColor=[UIColor grayColor];
                 self.touzhi.userInteractionEnabled=NO;
                 self.restTime.text=[return_dic objectForKey:@"state"];
             }
             //如果招标没有结束，那么倒计时继续
             else
             {
                 //倒计时,先获得当前时间的时间戳
                 int currenTime=[[NSDate date] timeIntervalSince1970];
                 //将投资剩余时间存入timeRest
                 timeRest=endTime-currenTime;
                 //用来倒计时
                 timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
             }
         }
         
         //活动指示器消失
         [activityView stopAnimating];
         [activityView removeFromSuperview];
         
     }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        //提示用户，请求出错
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"访问服务器出错，请检查网络连接状况" preferredStyle:UIAlertControllerStyleAlert];
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


//投资倒计时
-(void)countDown
{
    if (timeRest!=0)
    {
        //总时间减一；
        timeRest=timeRest-1;
        //剩余天数
        int day=timeRest/86400;
        //剩余小时
        int hour=(timeRest-86400*day)/3600;
        //剩余分钟
        int minute=(timeRest-86400*day-3600*hour)/60;
        //剩余秒
        int second=timeRest-86400*day-3600*hour-60*minute;
        self.restTime.text=[NSString stringWithFormat:@"%d天%d小时%d分钟%d秒",day,hour,minute,second];
    }
    else
        [timer invalidate];
    
    
    
    
}

//我要投资
- (IBAction)touzhi:(id)sender
{
        //用户已经登录
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userstate"] intValue]==1)
        {
            if (app.Rea_manager.reachable==YES)
            {
                UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                itemDetailView*detailView=[main instantiateViewControllerWithIdentifier:@"detail"];
                detailView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                //值传递
                detailView.get_dic=return_dic;
                //还需要把项目id传送过去
                detailView.itempid=self.itempid;
                [self presentViewController:detailView animated:YES completion:nil];

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
    else
        {
            //未登录，跳到登录界面
            UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SignInView*signinView=[main instantiateViewControllerWithIdentifier:@"signin"];
            signinView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            [self presentViewController:signinView animated:YES completion:nil];
        }
}

//
- (IBAction)back:(id)sender
{
    
    //视图消失时，可以释放一些对象，已节约内存
    
    [self dismissViewControllerAnimated:YES completion:^
    {
        array_List=nil;
        recordList=nil;
        toKnow=nil;
        timer=nil;
    }];
}

//根据分段控件的segment，来判断需要加载什么功能界面
- (IBAction)choseFounc:(id)sender
{
    if ((self.choseFounc.selectedSegmentIndex==0)&&(flag!=0))
    {
        //改变flag的值
        flag=0;
        //隐藏两个表视图
        [recordList removeFromSuperview];
        [toKnow removeFromSuperview];
        //主界面显示
        self.bgView.hidden=NO;
    }
    else if (self.choseFounc.selectedSegmentIndex==1&&flag!=1)
    {
        //先改变falg的值
        flag=1;
        //主界面和申购记录隐藏
        self.bgView.hidden=YES;
        //移除申购记录
        [recordList removeFromSuperview];
        //显示投资须知列表
        [self.view addSubview:toKnow];
        //重载数据
        [toKnow reloadData];
    }
    else if (self.choseFounc.selectedSegmentIndex==2&&flag!=2)
    {
        //先设置flag的值
        flag=2;
        //主界面和“投资须知”界面隐藏
        self.bgView.hidden=YES;
        //移除“投资须知”表视图
        [toKnow removeFromSuperview];
        //申购记录显示
        [self.view addSubview:recordList];
        
        if (array_List.count==0)
        {
            if (app.Rea_manager.reachable==YES)
            {
                //增加一个活动指示器
                [self.view addSubview:activityView];
                [activityView startAnimating];
                
                //如果无记录，说明是第一次请求，则向服务器请求数据
                NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:self.itempid,@"pid",@"10",@"count",[NSString stringWithFormat:@"%d",flag1],@"pager",nil];
                //向服务器请求数据
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investRecordList.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //数据请求成功者停止活动
                     //活动指示器消失
                     [activityView stopAnimating];
                     [activityView removeFromSuperview];
                     
                     if(operation.responseData)
                     {
                         NSArray*get_array=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                         //将数据存入可变数组
                         [array_List addObjectsFromArray:get_array];
                         //此处要重新加载表视图，因为表视图的协议方法调用比这要快
                         [recordList reloadData];
                         //页码数加一
                         flag1++;
                     }
                 }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     
                     //活动指示器消失
                     [activityView stopAnimating];
                     [activityView removeFromSuperview];
                }];

            }
            else
            {
                //提示用户打开网络
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                {
                    //设置定时器
                    timer1=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestAgain) userInfo:nil repeats:YES];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
 
            }
        }
        else
        {
            [recordList reloadData];
            [self.view addSubview:recordList];
        }
    }
}


//申购记录再次请求
-(void)requestAgain
{
    if (app.Rea_manager.reachable==YES)
    {
        
        //增加一个活动指示器
        [self.view addSubview:activityView];
        [activityView startAnimating];
        //如果无记录，说明是第一次请求，则向服务器请求数据
        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:self.itempid,@"pid",@"10",@"count",[NSString stringWithFormat:@"%d",flag1],@"pager",nil];
        //向服务器请求数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investRecordList.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //定时器取消
             [timer1 invalidate];
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             
             if(operation.responseData)
             {
                 NSArray*get_array=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 //将数据存入可变数组
                 [array_List addObjectsFromArray:get_array];
                 //此处要重新加载表视图，因为表视图的协议方法调用比这要快
                 [recordList reloadData];
                 //页码数加一
                 flag1++;
             }
         }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             
             //提示用户，请求出错
             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"访问服务器出现错误,请先检查手机网络连接状况" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];
         }];
    }
}

#pragma tableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (flag==1)
        return 2;
    else
    {
        if (array_List.count%10==0)
            return array_List.count+1;
        else
            return array_List.count;
    }
    
    
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (flag==1)
    {
        if (indexPath.row==0)
            return 44;
        else
            return 120;
    }
    else if(flag==2)
        return 60;
    else
        return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*identy=@"Cell";
    if (flag==1)
    {
        UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"项目描述";
            cell.backgroundColor=[UIColor grayColor];
            cell.textLabel.textColor=[UIColor blackColor];
        }
        else
        {
            //定义一个label，用来存放项目描述
            UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, toKnow.bounds.size.width, 120)];
            lab.numberOfLines=3;
            lab.font=[UIFont boldSystemFontOfSize:12];
            lab.textAlignment=NSTextAlignmentLeft;
            lab.textColor=[UIColor blackColor];
            lab.text=[return_dic objectForKey:@"depict"];
            [cell addSubview:lab];
        }
        
        return cell;
    }
    else if(flag==2)
    {
        if (indexPath.row==array_List.count)
        {
            //定义一个"加载更多"按钮
            UITableViewCell*cell=[[UITableViewCell alloc] init];
            UIButton*bt=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
            [bt setTitle:@"加载更多" forState:UIControlStateNormal];
            [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [bt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            //给按钮定义事件响应
            [bt addTarget:self action:@selector(forMore) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:bt];
            return cell;
        }
        else
        {
            //定义三个按钮，分别用来存放用户名，时间，和金额
            
            UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            //定义一个label用来存放username
            UILabel*username=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, 30)];
            username.text=[[array_List objectAtIndex:indexPath.row] objectForKey:@"name"];
            username.textColor=[UIColor blackColor];
            username.textAlignment=NSTextAlignmentCenter;
            username.font=[UIFont boldSystemFontOfSize:14];
            [cell addSubview:username];
            
            
            //将时间戳改为标准格式显示
            NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            //将时间戳改为NSDate类型
            NSDate*date1=[NSDate dateWithTimeIntervalSince1970:[[[array_List objectAtIndex:indexPath.row] objectForKey:@"time"] integerValue]];
            //定义一个label用来存放时间
            UILabel*time=[[UILabel alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width/2, 30)];
            time.textColor=[UIColor blackColor];
            time.textAlignment=NSTextAlignmentCenter;
            time.font=[UIFont boldSystemFontOfSize:14];
            time.text=[formatter stringFromDate:date1];
            [cell addSubview:time];
            
            //定义一个label，用来存放金额
            UILabel*money=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 0, [UIScreen mainScreen].bounds.size.width/2, 30)];
            money.textColor=[UIColor redColor];
            money.textAlignment=NSTextAlignmentRight;
            money.font=[UIFont boldSystemFontOfSize:14];
            money.text=[NSString stringWithFormat:@"%@元",[[array_List objectAtIndex:indexPath.row] objectForKey:@"money"]];
            [cell addSubview:money];
            
            return cell;
        }
    }
    else
        return nil;
}

//加载更多
-(void)forMore
{
    if (app.Rea_manager.reachable==YES)
    {
        //增加活动指示器
        [self.view addSubview:activityView];
        [activityView startAnimating];
        
        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:self.itempid,@"pid",@"10",@"count",[NSString stringWithFormat:@"%d",flag1],@"pager",nil];
        //向服务器请求数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investRecordList.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             
             if(operation.responseData)
             {
                 NSArray*get_array=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 
                 //将数据存入可变数组
                 [array_List addObjectsFromArray:get_array];
                 //页码数加一
                 flag1++;
                 //此处要重新加载表视图，因为表视图的协议方法调用比这要快
                 [recordList reloadData];
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
        //提示用户，请求出错
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}



@end
