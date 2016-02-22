//
//  PayCashView.m
//  ToLoan
//
//  Created by jway on 15-5-1.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "PayCashView.h"
#import "AppDelegate.h"
#import "UserCentreView.h"
#import "TabBarView.h"
#import <CommonCrypto/CommonDigest.h>
#import "BaoFooPayController.h"
@interface PayCashView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    
}

@end

@implementation PayCashView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //修饰背景图的外观
    self.bgView.layer.cornerRadius=4.0f;
    self.bgView.layer.borderColor=[[UIColor blueColor] CGColor];
    self.bgView.layer.borderWidth=1.0f;
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    //定义一个手势处理器。关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//关闭键盘
-(void)handTap
{
    [self.password resignFirstResponder];
}

- (IBAction)confirm:(id)sender
{
    //先判断是否支付密码已经填写
 if (![self.password.text isEqual:@""])
   {
      //如果网络连接是断开的，就提示用户
      if (app.Rea_manager.reachable==NO)
      {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
       }
      else
      {
        //在这里判断是提现还是投资项目
          //如果是投资项目
          if ([self.flag intValue]==1)
          {
              //构造发送数据
              NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",self.money_num,@"money",[self md5HexDigest:self.password.text],@"paypass",self.itempid,@"pid",nil];
              
              NSLog(@"投资项目send=%@",send_dic);
              
              //向服务器发送数据
              [app.manager POST:@"http://www.xiangnidai.com/dcs/app/investProject.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
              {
                  //服务器返回数据成功
                  NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                  
                  NSLog(@"投资项目get=%@",get_dic);
                  
                  if ([[get_dic objectForKey:@"state"] intValue]==1)
                  {
                      //支付成功，弹出提示
                      //支付成功，跳转界面到“首页推荐”
                      UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"支付成功" preferredStyle:UIAlertControllerStyleAlert];
                      UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                            {
                                                //跳转界面
                                                UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                TabBarView*mainView=[main instantiateViewControllerWithIdentifier:@"mainbar"];
                                                mainView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                                                [self presentViewController:mainView animated:YES completion:nil];
                                            }];
                      [alert addAction:action];
                      [self presentViewController:alert animated:YES completion:nil];
                      
                  }
                  else
                  {
                      //支付失败
                      UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                      UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                      [alert addAction:action];
                      [self presentViewController:alert animated:YES completion:nil];

                  }
                  
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error)
               {
                  //
                   
              }];
              
              
          }
          //如果是提现
          else
          {
              //构造发送数据
              NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",self.money_num,@"money",[self md5HexDigest:self.password.text],@"paypass",nil];
              
              NSLog(@"提现send=%@",send_dic);
              
              //向服务器发送数据
              [app.manager POST:@"http://www.xiangnidai.com/dcs/app/cash.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
               {
                   //获取服务器返回数据
                   NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                   
                   NSLog(@"提现get=%@",get_dic);
                   
                   //判断是否支付成功
                   if ([[get_dic objectForKey:@"state"] intValue]==1)
                   {
                       //支付成功，跳转界面到“财富中心”
                       UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"提现成功" preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                             {
                                                 //跳转界面
                                                 UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                 UserCentreView*cenView=[main instantiateViewControllerWithIdentifier:@"usercentre"];
                                                 cenView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                                                 [self presentViewController:cenView animated:YES completion:nil];
                                             }];
                       
                       [alert addAction:action];
                       [self presentViewController:alert animated:YES completion:nil];
                   }
                   else
                   {
                       UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                       [alert addAction:action];
                       [self presentViewController:alert animated:YES completion:nil];
                   }
                   
               }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error)
               {
                   //
               }];
          }
          
       }
   }
   else
   {
        //如果未填写支付密码，提示用户
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请先填写支付密码" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//MD5算法加密
-(NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02X",result[i]];
    }
    return ret;
}


@end
