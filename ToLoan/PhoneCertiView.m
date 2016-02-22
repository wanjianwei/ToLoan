//
//  PhoneCertiView.m
//  ToLoan
//
//  Created by jway on 15-4-27.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "PhoneCertiView.h"
#import "AppDelegate.h"
@interface PhoneCertiView ()
{
    AppDelegate*app;
    //设置倒计时
    int flag;
    //定义一个定时器
    NSTimer*time;
    //定义一个字典，用来存放服务器返回数据
    NSDictionary*get_dic;
}

@end

@implementation PhoneCertiView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //已认证显示图外观修饰
    self.hasCertiCiew.layer.borderColor=[[UIColor blueColor] CGColor];
    self.hasCertiCiew.layer.borderWidth=1.0f;
    self.hasCertiCiew.layer.cornerRadius=2.0f;
    
    //修饰外观属性
    self.phoneBgView.layer.borderWidth=1.0f;
    self.phoneBgView.layer.cornerRadius=2.0f;
    self.phoneBgView.layer.borderColor=[[UIColor grayColor] CGColor];
    //“验证码输入框”外观
    self.randomNum.layer.borderWidth=1.0f;
    self.randomNum.layer.cornerRadius=2.0f;
    self.randomNum.layer.borderColor=[[UIColor grayColor] CGColor];
    //获取验证码按钮外观
    self.getRandom.layer.cornerRadius=2.0f;
    self.getRandom.layer.borderColor=[[UIColor grayColor] CGColor];
    self.getRandom.layer.borderWidth=1.0f;
    
    //先给出待认证号码
    if ([[self.certi_dic objectForKey:@"isCrte"] intValue]==1)
    {
        //如果已经认证过
        self.certiNum.text=[NSString stringWithFormat:@"%@",[self.certi_dic objectForKey:@"phoneNum"]];
    }
    else
    {
        self.hasCertiCiew.hidden=YES;
    }
    
    //指定协议
    self.telPhone.delegate=self;
    self.randomNum.delegate=self;
    //实例化
    app=[UIApplication sharedApplication].delegate;
    
    //手势处理器，关闭键盘
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
    [self.telPhone resignFirstResponder];
    [self.randomNum resignFirstResponder];
}

- (IBAction)getRandom:(id)sender
{
    //如果手机号为空，弹出提示
    if ([self.telPhone.text isEqual:@""])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"手机号不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        //手机号码不为空
        //手机号以13， 15，18开头，八个 \d 数字字符
        NSString *phoneRegex = @"^(1[0-9]{10})$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        
        if (![phoneTest evaluateWithObject:self.telPhone.text])
        {
            //手机号码不合法
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"手机号不合法" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else
        {
            if (app.Rea_manager.reachable==YES)
            {
                //开启一个定时器，用来获取倒计时
                time=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(count) userInfo:nil repeats:YES];
                flag=120;
                //取消按钮的可交互性
                self.getRandom.userInteractionEnabled=NO;
                
                
                //发送数据
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/sendMobileCodeForFindLoginPwd.do" parameters:[NSDictionary dictionaryWithObject:self.telPhone.text forKey:@"phonenum"] success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //将数据存储
                     get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     
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

    }
}

//获取验证码倒计时操作
-(void)count
{
    flag=flag-1;
    
    if (flag!=0)
    {
        [self.getRandom setTitle:[NSString stringWithFormat:@"剩余%d秒",flag] forState:UIControlStateNormal];
    }
    else
    {
        //定时器关闭
        [time invalidate];
        //按钮标题恢复
        [self.getRandom setTitle:@"获取验证码" forState:UIControlStateNormal];
        //恢复按钮的可交互性
        self.getRandom.userInteractionEnabled=YES;
    }

}
//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        self.certi_dic=nil;
    }];
}

#pragma delegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ((textField.tag==2)&&![textField.text isEqual:@""])
    {
        //判断验证码是否输入正确
        if ([textField.text isEqual:[get_dic objectForKey:@"code"]])
        {
            //验证码输入正确，计时器停止工作
            [time invalidate];
            [self.getRandom setTitle:@"获取验证码" forState:UIControlStateNormal];
            //恢复按钮可交互性
            self.getRandom.userInteractionEnabled=YES;
            
        }
        else
        {
            //弹出提示，验证码错误
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"验证码输入错误" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                //如果计时器还在工作
                if (time.valid==YES)
                {
                    [time invalidate];
                    [self.getRandom setTitle:@"获取验证码" forState:UIControlStateNormal];
                    //恢复按钮可交互性
                    self.getRandom.userInteractionEnabled=YES;

                }
                
                //将不合法的输入清空
                textField.text=@"";
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if ((textField.tag==1)&&![textField.text isEqual:@""])
    {
        //手机号码不为空
        //手机号以13， 15，18开头，八个 \d 数字字符
        NSString *phoneRegex = @"^(1[0-9]{10})$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        
        if (![phoneTest evaluateWithObject:textField.text])
        {
            //手机号码不合法
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"手机号不合法" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                //不合法输入设置为空
                textField.text=@"";
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }
    
}

//点击下一步操作
- (IBAction)nextStep:(id)sender
{
    //先关闭键盘
    [self.telPhone resignFirstResponder];
    [self.getRandom resignFirstResponder];
    
    //先判断手机号和验证码是否为空
    if ([self.telPhone.text isEqual:@""]||[self.randomNum.text isEqual:@""])
    {
        //提示用户将信息填写完整
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请将上述信息填写完整" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
       //此处应该进行随机码的验证
        if (![self.randomNum.text isEqual:[get_dic objectForKey:@"code"]])
        {
            //提示用户将信息填写完整
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"验证码输入错误" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            //判断网络连接是否断开
            if (app.Rea_manager.reachable==YES)
            {
                //构造发射数据
                NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",self.telPhone.text,@"phonenum",self.randomNum.text,@"cord",nil];
                
                //请求服务器获取数据
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/verifyMobile.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //数据成功返回
                     NSDictionary*return_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     
                     NSLog(@"return_dic=%@",return_dic);
                     
                     //如果认证成功
                     if ([[return_dic objectForKey:@"issuccess"] intValue]==1)
                     {
                         //如果成功，弹出提示框返回原来界面，并调用代理
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"手机认证成功" preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                               {
                                                   //更新认证信息
                                                   [self.delegate hasPhoneCerti:self.telPhone.text];
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }];
                         
                         [alert addAction:action];
                         [self presentViewController:alert animated:YES completion:^{
                             //从上一个视图传来的认证信息删除
                             self.certi_dic=nil;
                             
                         }];
                         
                     }
                     else
                     {
                         //提示用户，认证失败
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[return_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                         [alert addAction:action];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
                     
                     
                 }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     
                 }];
                
            }
            else
            {
                //提示用户，请求出错
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
        
        
    }
}
@end
