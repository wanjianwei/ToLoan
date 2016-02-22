//
//  FinishbankCertiView.m
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "FinishbankCertiView.h"
#import "AppDelegate.h"
#import "MyInfoView.h"

@interface FinishbankCertiView ()
{
    //定义一个程序委托
    AppDelegate*app;
   
}


@end

@implementation FinishbankCertiView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //修饰输入金额框的背景
    self.numBg.layer.cornerRadius=2.0f;
    self.numBg.layer.borderColor=[[UIColor grayColor] CGColor];
    self.numBg.layer.borderWidth=1.0f;
    
    //修饰按钮属性
    self.moveBind.layer.cornerRadius=3.0f;
    self.moveBind.layer.borderWidth=1.0f;
    self.moveBind.layer.borderColor=[[UIColor blueColor] CGColor];
    
    //实例化程序委托
    app=[UIApplication sharedApplication].delegate;
    
    //注册一个手势处理器，关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//关闭键盘
-(void)handTap
{
    [self.money_num resignFirstResponder];
}


//认证
- (IBAction)certificate:(id)sender
{
    //先判断当前网络连接状态
    if (app.Rea_manager.reachable==YES)
    {
        //构造发送数据
        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",[NSNumber numberWithFloat:[self.money_num.text floatValue]],@"money",nil];
        //向服务器发送数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/bindBankCommit.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
            
            if ([[get_dic objectForKey:@"state"] intValue]==1)
            {
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"银行卡认证成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                    {
                        
                        //利用通知将认证状态广播出去
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateState" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"state",self.cardID,@"cardID",nil]];
                        
                        //取消视图
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            else
            {
                //提示用户，认证失败
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            //提示用户，请求出错
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"服务器或网络出现异常" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];

        }];
    }
    else
    {
        //提示用户，检查网络
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//解除绑定
- (IBAction)moveBind:(id)sender
{
    if (app.Rea_manager.reachable==YES)
    {
        //网络连接正常
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/unbindUserBank.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
            
            if ([[get_dic objectForKey:@"state"] intValue]==1)
            {
                
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"解除绑定成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                {
                    //利用通知将认证状态广播出去
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"moveBindNot" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"state",@"0",@"cardID",nil]];
                    
                    //取消视图
                    [self dismissViewControllerAnimated:YES completion:nil];

                }];
                
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            }
            else
            {
                //解除绑定失败
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"]  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //提示用户，请求出错
             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"服务器或网络出现异常" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];

        }];
    }
    else
    {
        //提示用户，检查网络
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//返回操作-此刻返回说明银行卡绑定成功，但是认证失败
- (IBAction)back:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}
@end
