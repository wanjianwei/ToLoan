//
//  ItemRecommendViewController.m
//  ToLoan
//
//  Created by jway on 15-4-19.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "ItemRecommendViewController.h"
#import "AppDelegate.h"
#import "BasicInfoView.h"
@interface ItemRecommendViewController ()
{
    //定义一个程序委托类
    AppDelegate*app;
    
    //定义一个字典型数据，用于存放服务器返回的数据
    NSDictionary*get_dic;
    //定义一个定时器
    NSTimer*timer;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView;
    
}

@end

@implementation ItemRecommendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 修饰按钮属性
    self.cathectic.layer.cornerRadius=5.0f;
    //设置展示动态图片
    self.DisImage.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"default_page.png"],[UIImage imageNamed:@"centre.png"],nil];
    self.DisImage.animationDuration=3;
    //无限循环
    self.DisImage.animationRepeatCount=0;
    [self.DisImage startAnimating];
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    //定义一个活动指示器
    activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
    [self.view addSubview:activityView];
    [activityView startAnimating];
    //立即投资按钮的
    
    //向服务器请求数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/recommandedProject.do" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
             if (operation.responseData)
             {
                 
                 //取出数据
                 get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 
                 //在这加载label--限期
                 UILabel*time=[[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-137, [UIScreen mainScreen].bounds.size.width/3, 16)];
                 time.textAlignment=NSTextAlignmentCenter;
                 time.textColor=[UIColor grayColor];
                 time.font=[UIFont boldSystemFontOfSize:13];
                 //取出截止时间减去起始时间就是限期
                 int startTime=[[[get_dic objectForKey:@"project"] objectForKey:@"startTime"] intValue];
                 
                 int endTime=[[[get_dic objectForKey:@"project"] objectForKey:@"endTime"] intValue];
                 time.text=[NSString stringWithFormat:@"限期:%i天",(endTime-startTime)/86400];
                 //加载到view视图中
                 [self.view addSubview:time];
                 
                 
                 //起购金额label
                 UILabel*minbuy=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height-137, [UIScreen mainScreen].bounds.size.width/3, 16)];
                 minbuy.textAlignment=NSTextAlignmentCenter;
                 minbuy.textColor=[UIColor grayColor];
                 minbuy.font=[UIFont boldSystemFontOfSize:13];
                 minbuy.text=[NSString stringWithFormat:@"%@起购",[[get_dic objectForKey:@"project"] objectForKey:@"minbuy"]];
                 [self.view addSubview:minbuy];
                 
                 
                 //剩余金额
                 UILabel*mon_rest=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*2/3, [UIScreen mainScreen].bounds.size.height-137, [UIScreen mainScreen].bounds.size.width/3, 16)];
                 mon_rest.textAlignment=NSTextAlignmentCenter;
                 mon_rest.textColor=[UIColor grayColor];
                 mon_rest.font=[UIFont boldSystemFontOfSize:13];
                 
                 mon_rest.text=[NSString stringWithFormat:@"剩余%i元",[[[get_dic objectForKey:@"project"] objectForKey:@"ptotal"] intValue]-[[[get_dic objectForKey:@"project"] objectForKey:@"comp"] intValue]];
                 [self.view addSubview:mon_rest];
                 
                 
                 //返回的是整型,
                 self.make_total_money.text=[NSString stringWithFormat:@"为客户赚取:%i元",[[get_dic objectForKey:@"make_total_money"] intValue]];
                 
                 self.interest.text=[NSString stringWithFormat:@"%@年化率",[[get_dic objectForKey:@"project"] objectForKey:@"interest"]];
                 
                 self.buycount.text=[NSString stringWithFormat:@"%i人已购买",[[[get_dic objectForKey:@"project"] objectForKey:@"buyCount"] intValue]];
                 
                 self.percent.text=[NSString stringWithFormat:@"%2.0f%%",[[[get_dic objectForKey:@"project"] objectForKey:@"comp"] intValue]/(float)[[[get_dic objectForKey:@"project"] objectForKey:@"ptotal"] intValue]*100];
                 
                 //设置利率圆弧的外观属性
                 [self.ProgImage setStrokeWidth:8.0];
                 [self.ProgImage setProgress:[[[get_dic objectForKey:@"project"] objectForKey:@"comp"] intValue]/(float)[[[get_dic objectForKey:@"project"] objectForKey:@"ptotal"] intValue]];
                 
                 [self.ProgImage startAnimation];
                 //成功了活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
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
    [self performSelector:@selector(judgeNet) withObject:nil afterDelay:1.0];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//待程序已经启动一段时间后判断网络连接状况
-(void)judgeNet
{
    if (app.Rea_manager.reachable==NO)
        
    {
        //网络未连接
        //提示用户，检查网络
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        //再次定义一个定时器，程序一旦进入后台，定时器就关闭了检测网络
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestAgain) userInfo:nil repeats:YES];
    }
}

-(void)requestAgain
{
    if (app.Rea_manager.reachable==YES)
    {
        
        //定义一个活动指示器
        [self.view addSubview:activityView];
        [activityView startAnimating];
        //再次向服务器请求数据
        //向服务器请求数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/recommandedProject.do" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if (operation.responseData)
             {
                 
                 //取出数据
                 get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 
                 //在这加载label--限期
                 UILabel*time=[[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-137, [UIScreen mainScreen].bounds.size.width/3, 16)];
                 time.textAlignment=NSTextAlignmentCenter;
                 time.textColor=[UIColor grayColor];
                 time.font=[UIFont boldSystemFontOfSize:13];
                 //取出截止时间减去起始时间就是限期
                 int startTime=[[[get_dic objectForKey:@"project"] objectForKey:@"startTime"] intValue];
                 
                 int endTime=[[[get_dic objectForKey:@"project"] objectForKey:@"endTime"] intValue];
                 time.text=[NSString stringWithFormat:@"限期:%i天",(endTime-startTime)/86400];
                 //加载到view视图中
                 [self.view addSubview:time];
                 
                 
                 //起购金额label
                 UILabel*minbuy=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height-137, [UIScreen mainScreen].bounds.size.width/3, 16)];
                 minbuy.textAlignment=NSTextAlignmentCenter;
                 minbuy.textColor=[UIColor grayColor];
                 minbuy.font=[UIFont boldSystemFontOfSize:13];
                 minbuy.text=[NSString stringWithFormat:@"%@起购",[[get_dic objectForKey:@"project"] objectForKey:@"minbuy"]];
                 [self.view addSubview:minbuy];
                 
                 
                 //剩余金额
                 UILabel*mon_rest=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*2/3, [UIScreen mainScreen].bounds.size.height-137, [UIScreen mainScreen].bounds.size.width/3, 16)];
                 mon_rest.textAlignment=NSTextAlignmentCenter;
                 mon_rest.textColor=[UIColor grayColor];
                 mon_rest.font=[UIFont boldSystemFontOfSize:13];
                 
                 mon_rest.text=[NSString stringWithFormat:@"剩余%i元",[[[get_dic objectForKey:@"project"] objectForKey:@"ptotal"] intValue]-[[[get_dic objectForKey:@"project"] objectForKey:@"comp"] intValue]];
                 [self.view addSubview:mon_rest];
                 
                 
                 //返回的是整型,
                 self.make_total_money.text=[NSString stringWithFormat:@"为客户赚取:%i元",[[get_dic objectForKey:@"make_total_money"] intValue]];
                 
                 self.interest.text=[NSString stringWithFormat:@"%@年化率",[[get_dic objectForKey:@"project"] objectForKey:@"interest"]];
                 
                 self.buycount.text=[NSString stringWithFormat:@"%i人已购买",[[[get_dic objectForKey:@"project"] objectForKey:@"buyCount"] intValue]];
                 
                 self.percent.text=[NSString stringWithFormat:@"%2.0f%%",[[[get_dic objectForKey:@"project"] objectForKey:@"comp"] intValue]/(float)[[[get_dic objectForKey:@"project"] objectForKey:@"ptotal"] intValue]*100];
                 
                 //设置利率圆弧的外观属性
                 [self.ProgImage setStrokeWidth:8.0];
                 [self.ProgImage setProgress:[[[get_dic objectForKey:@"project"] objectForKey:@"comp"] intValue]/(float)[[[get_dic objectForKey:@"project"] objectForKey:@"ptotal"] intValue]];
                 
                 [self.ProgImage startAnimation];
                 //再次请求数据成功，把定时器注销
                 [timer invalidate];
                 
                 //活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
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
    
}


//我要投资
- (IBAction)cathectic:(id)sender
{
    if (app.Rea_manager.reachable==YES)
    {
        //此处直接跳转
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BasicInfoView*infoView=[main instantiateViewControllerWithIdentifier:@"basicinfo"];
        infoView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        
        //把项目的id传给下一个视图
        infoView.itempid=[[get_dic objectForKey:@"project"] objectForKey:@"pid"];
        [self presentViewController:infoView animated:YES completion:nil];
    }
    else
    {
        //弹出提示，让用户打开网络连接
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
@end
