//
//  ForgetPWView.m
//  ToLoan
//
//  Created by jway on 15-4-29.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "ForgetPWView.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
@interface ForgetPWView ()
{
   //定义一个程序委托类
    AppDelegate*app;
    //定义一个定时器
    NSTimer*time;
    //定义一个计时数
    int flag;
    //定义一个字典，用来存放请求验证码返回的数据
    NSDictionary*get_dic;
}

@end

@implementation ForgetPWView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理
    self.telPhone.delegate=self;
    self.randomNum.delegate=self;
    self.newpasswd.delegate=self;
    
    //修饰控件外观
    self.phoneBg.layer.cornerRadius=4.0f;
    self.phoneBg.layer.borderColor=[[UIColor grayColor] CGColor];
    self.phoneBg.layer.borderWidth=1.0f;
    
    self.randonbg.layer.cornerRadius=4.0f;
    self.randonbg.layer.borderColor=[[UIColor grayColor] CGColor];
    self.randonbg.layer.borderWidth=1.0f;
    
    self.passwdbg.layer.cornerRadius=4.0f;
    self.passwdbg.layer.borderColor=[[UIColor grayColor] CGColor];
    self.passwdbg.layer.borderWidth=1.0f;
    
    //获取验证码按钮外观
    self.getNum.layer.cornerRadius=4.0f;
    self.getNum.layer.borderWidth=1.0f;
    self.getNum.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    
    //注册手势处理器关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//关闭键盘操作
-(void)handTap
{
    [self.telPhone resignFirstResponder];
    [self.randomNum resignFirstResponder];
    [self.newpasswd resignFirstResponder];
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//下一步
- (IBAction)nextStep:(id)sender
{
    if ([self.telPhone.text isEqual:@""]||[self.randomNum.text isEqual:@""]||[self.newpasswd.text isEqual:@""])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请将上述信息填写完整" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];

    }
    else
    {
        //在这里要判断新输入密码是否符合要求
        //匹配由数字、字母组成的字符串
        NSString*format=@"^[A-Z0-9a-z]{6,24}+$";
        NSPredicate*textTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",format];
        if(![textTest evaluateWithObject:self.newpasswd.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"新密码格式不符合要求"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                  {
                                      self.newpasswd.text=@"";
                                  }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            //向服务器请求
            //如果网络连接正常
            if (app.Rea_manager.reachable==YES)
            {
                //构造发送数据
                NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:self.telPhone.text,@"phonenum",[self md5HexDigest:self.newpasswd.text],@"newpass",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",nil];
                
                //向服务器发送数据
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/setLoginPwd.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //判断是否重新设置密码成功
                     NSDictionary*return_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     
                     if ([[return_dic objectForKey:@"state"] intValue]==1)
                     {
                         //重新设置密码成功
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"密码重新设置成功" preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                               {
                                                   //重新回到上级视图
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }];
                         [alert addAction:action];
                         [self presentViewController:alert animated:YES completion:nil];
                         
                     }
                     else
                     {
                         //重新设置密码成功
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[return_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
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
                //提示用户打开网络
                //提示用户，请求出错
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

//获取验证码--要先判断手机号输入是否合法
- (IBAction)getNum:(id)sender
{
        //手机号以13， 15，18开头，八个 \d 数字字符
        NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        if (![phoneTest evaluateWithObject:self.telPhone.text])
         {
            //手机号码不合法
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"手机号不合法" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                  {
                                      //如果手机不合法，则清空
                                      self.telPhone.text=@"";
                                  }];
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
                self.getNum.userInteractionEnabled=NO;
                
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
                //提示用户，请求出错
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
}

//获取验证码倒计时操作
-(void)count
{
    flag=flag-1;
    
    if (flag!=0)
    {
        [self.getNum setTitle:[NSString stringWithFormat:@"剩余(%d)秒",flag] forState:UIControlStateNormal];
    }
    else
    {
        //定时器关闭
        [time invalidate];
        //按钮标题恢复
        [self.getNum setTitle:@"获取验证码" forState:UIControlStateNormal];
        //恢复按钮的可交互性
        self.getNum.userInteractionEnabled=YES;
    }
    
}


#pragma textField
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==1&&![textField.text isEqual:@""])
    {
        //输入合法性判断
        //手机号以13， 15，18开头，八个 \d 数字字符
        NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        
        if (![phoneTest evaluateWithObject:textField.text])
        {
            //手机号码不合法
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"手机号不合法" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                  {
                                      //如果手机不合法，则清空
                                      textField.text=@"";
                                  }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if (textField.tag==2&&![textField.text isEqual:@""])
    {
        //验证码验证判断
        //判断验证码是否输入正确
        if ([textField.text isEqual:[get_dic objectForKey:@"code"]])
        {
            //验证码输入正确，计时器停止工作
            [time invalidate];
            [self.getNum setTitle:@"获取验证码" forState:UIControlStateNormal];
            //恢复按钮可交互性
            self.getNum.userInteractionEnabled=YES;
            
        }
        else
        {
            //弹出提示，验证码错误
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"验证码输入错误" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                  {
                                      //验证码设置为空
                                      self.randomNum.text=@"";
                                      //如果计时器还在工作
                                      if (time.valid==YES)
                                      {
                                          [time invalidate];
                                          [self.getNum setTitle:@"获取验证码" forState:UIControlStateNormal];
                                          //恢复按钮可交互性
                                          self.getNum.userInteractionEnabled=YES;
                                          
                                      }
                                  }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if(textField.tag==3&&![textField.text isEqual:@""])
    {
        //新密码合法性验证
        //新密码要包含数字与字母
        //匹配由数字、字母组成的字符串
        NSString*format=@"^[A-Z0-9a-z]{6,24}+$";
        NSPredicate*textTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",format];
        if(![textTest evaluateWithObject:textField.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"新密码格式不符合要求"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                textField.text=@"";
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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
