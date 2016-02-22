//
//  BankCertiSucView.m
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "BankCertiSucView.h"
#import "AppDelegate.h"

@interface BankCertiSucView ()
{
    //定义一个程序委托
    AppDelegate*app;
}

@end

@implementation BankCertiSucView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //修饰外观属性
    self.bg.layer.cornerRadius=4.0f;
    self.bg.layer.borderColor=[[UIColor blueColor] CGColor];
    self.bg.layer.borderWidth=1.0f;
    
    //解除绑定按钮外观
    self.moveBind.layer.borderWidth=1.0f;
    self.moveBind.layer.cornerRadius=4.0f;
    self.moveBind.layer.borderColor=[[UIColor grayColor] CGColor];
    
    //设定绑定银行卡号
    self.bankNum.text=self.cardID;
    //实例化
    app=[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
                 //解除绑定成功,跳转到“我的资料”,不需要更新状态
                 UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"解除绑定成功" preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                 {
                     //需要更新状态，同样是通过通知来更新状态
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateState" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"state",@"0",@"cardID",nil]];
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
@end
