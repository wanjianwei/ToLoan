//
//  CheckCardInfoView.m
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "CheckCardInfoView.h"
#import "AppDelegate.h"
#import "FinishbankCertiView.h"
@interface CheckCardInfoView ()
{
    //定义一个程序委托
    AppDelegate*app;
}

@end

@implementation CheckCardInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //开户姓名
    self.username.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    
    //开户银行
    self.bankName.text=self.bakName_temp;
    
    //银行卡号
    self.bankNum.text=self.cardID;
    
    //实例化程序委托
    app=[UIApplication sharedApplication].delegate;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//点击下一步，向服务器发送银行卡信息
- (IBAction)nextStep:(id)sender

{
    if (app.Rea_manager.reachable==YES)
    {
        //如果网络连接正常
        //构造发送数据
        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",[NSString stringWithFormat:@"%@",self.bankid],@"bankid",self.cardID,@"bankno",nil];
        
        //向服务器发送
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/bindBank.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
           
            NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
            if ([[get_dic objectForKey:@"issuccess"] intValue]==1)
            {
                //成功跳转到下一个界面
                UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FinishbankCertiView*finishView=[main instantiateViewControllerWithIdentifier:@"finishcerti"];
                finishView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                
                //采用广播的形式将银行卡号广播出去，目的是为了使“我的资料”界面即使更新银行卡号的认证状态
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bankNumChecked" object:nil userInfo:[NSDictionary dictionaryWithObject:self.cardID forKey:@"cardID"]];
                
                //并且将银行卡得信息传递给下一个视图
                finishView.cardID=self.cardID;
                
                [self presentViewController:finishView animated:YES completion:nil];
                
            }
            else
            {
                //绑定失败
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
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
        //提示用户网络连接断开
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往“设置”中打开" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

//返回
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
