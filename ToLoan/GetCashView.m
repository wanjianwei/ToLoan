//
//  GetCashView.m
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "GetCashView.h"
#import "AppDelegate.h"
#import "PayCashView.h"
#import "MyInfoView.h"
@interface GetCashView ()
{
    //定义一个程序委托
    AppDelegate*app;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView;
    
}

@end

@implementation GetCashView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //实例化程序委托
    app=[UIApplication sharedApplication].delegate;
    
    //修饰背景
    self.bgView1.layer.cornerRadius=3.0f;
    self.bgView1.layer.borderColor=[[UIColor grayColor] CGColor];
    self.bgView1.layer.borderWidth=1.0f;
    
    self.bgView2.layer.cornerRadius=3.0f;
    self.bgView2.layer.borderColor=[[UIColor grayColor] CGColor];
    self.bgView2.layer.borderWidth=1.0f;
    
    
    //定义一个手势处理器，关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
    //定义一个活动指示器
    activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    //此时“去认证或下一步按钮”的可交互性设置为NO
    self.nextStep.userInteractionEnabled=NO;
    
    //此处要用到多线程
    //创建并发队列
    dispatch_queue_t concurrentQueue=dispatch_queue_create("wanjway", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentQueue, ^
    {
        //获取可用余额
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getAccountInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if (operation.responseData!=nil)
            {
                //获取数据
                NSDictionary*get_dic1=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                
                //在主线程上更新数据
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    self.money.text=[NSString stringWithFormat:@"%@元",[get_dic1 objectForKey:@"balance"]];
                });
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            //
        }];
        
    });
    
    //获取认证状态
    dispatch_async(concurrentQueue, ^
    {
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getVerifyInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if (operation.responseData!=nil)
            {
                //获取数据
                NSDictionary*get_dic2=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                
                //在主线程上更新数据
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   if ([[[get_dic2 objectForKey:@"bank"] objectForKey:@"isCrte"] intValue]==1)
                                   {
                                       //已经认证了
                                       //将按钮标题设置为“下一步”
                                       [self.nextStep setTitle:@"下一步" forState:UIControlStateNormal];
                                       
                                       //请求剩余免费提现额度和多处部分所收到的手续费
                                       dispatch_async(concurrentQueue, ^
                                       {
                                           [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getFreeAmount.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
                                           {
                                               //请求数据成功
                                               NSDictionary*get_dic3=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                                               
                                               //返回到主线程更新界面
                                               dispatch_async(dispatch_get_main_queue(), ^
                                               {
                                                   //此步最后一步完成，故活动指示器在此处消失
                                                   [activityView stopAnimating];
                                                   [activityView removeFromSuperview];
                                                   //恢复按钮的可交互性
                                                   self.nextStep.userInteractionEnabled=YES;
                                                   
                                                   //更新asset_info的信息
                                                   self.asset_info.text=[NSString stringWithFormat:@"您当前的免费提现额度为%@元，多出部分将收取%@元的手续费",[get_dic3 objectForKey:@"free"],[get_dic3 objectForKey:@"percent"]];
                                               });
                                               
                                           }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                           {
                                               //此步最后一步完成，故活动指示器在此处消失
                                               [activityView stopAnimating];
                                               [activityView removeFromSuperview];
                                               //恢复按钮的可交互性
                                               self.nextStep.userInteractionEnabled=YES;
                                           }];
                                       });
                                   }
                                   else
                                   {
                                       
                                       //此步最后一步完成，故活动指示器在此处消失
                                       [activityView stopAnimating];
                                       [activityView removeFromSuperview];
                                       //恢复按钮的可交互性
                                       self.nextStep.userInteractionEnabled=YES;
                                       //如果没有进行银行卡认证，去认证
                                       //先设置按钮标题
                                       [self.nextStep setTitle:@"去认证" forState:UIControlStateNormal];
                                       //隐藏输入金额框
                                       self.bgView2.hidden=YES;
                                       //增加一个自定义的UIView
                                       UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake(24, 163, [UIScreen mainScreen].bounds.size.width-48, 50)];
                                       lab.backgroundColor=[UIColor orangeColor];
                                       lab.textAlignment=NSTextAlignmentCenter;
                                       lab.font=[UIFont boldSystemFontOfSize:17];
                                       lab.textColor=[UIColor blackColor];
                                       lab.text=@"您尚未完成银行卡认证";
                                       
                                       //lab的外观
                                       lab.layer.cornerRadius=4.0f;
                                       lab.layer.borderColor=[[UIColor redColor] CGColor];
                                       lab.layer.borderWidth=1.0f;
                                       [self.view addSubview:lab];
                                       
                                   }
                               });
            }

        }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            //
        }];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//关闭键盘
-(void)handTap
{
    [self.getMoney resignFirstResponder];
}


//下一步操作
- (IBAction)nextStep:(id)sender
{
    UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //根据按钮的标题来下一步操作
    if ([self.nextStep.titleLabel.text isEqual:@"下一步"])
    {
        //已经进行银行卡验证，跳转到下一步“支付”界面
        PayCashView*payView=[main instantiateViewControllerWithIdentifier:@"paycash"];
        //将提现金额传递给下一界面
        payView.money_num=self.getMoney.text;
        payView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:payView animated:YES completion:nil];
        
    }
    else
    {
        //跳转到认证页面
        MyInfoView*infoView=[main instantiateViewControllerWithIdentifier:@"myinfo"];
        infoView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:infoView animated:YES completion:nil];
    }
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
