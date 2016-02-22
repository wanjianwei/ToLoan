//
//  PasswordCerti.m
//  ToLoan
//
//  Created by jway on 15-4-29.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "PasswordCerti.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
@interface PasswordCerti ()
{
    //程序委托类
    AppDelegate*app;
}

@end

@implementation PasswordCerti

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理
    self.pw1.delegate=self;
    self.pw2.delegate=self;
    self.pw3.delegate=self;
    //修饰按钮外观
    self.pw1.layer.cornerRadius=5.0f;
    self.pw1.layer.borderColor=[[UIColor grayColor] CGColor];
    self.pw1.layer.borderWidth=1.0f;
    self.pw2.layer.cornerRadius=5.0f;
    self.pw2.layer.borderColor=[[UIColor grayColor] CGColor];
    self.pw2.layer.borderWidth=1.0f;
    self.pw3.layer.cornerRadius=5.0f;
    self.pw3.layer.borderColor=[[UIColor grayColor] CGColor];
    self.pw3.layer.borderWidth=1.0f;
    
    //填写视图的标题
    self.viewTitle.text=self.viewTitle_temp;
    
    //注册手势处理器
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
    //判断当前是支付密码还是登陆密码
    if ([self.viewTitle_temp isEqual:@"支付密码"])
    {
        //已经设置过支付密码
        if ([self.flag intValue]==1)
        {
            self.pw1.placeholder=@"请输入原支付密码";
            self.pw2.placeholder=@"请输入新支付密码";
            self.pw3.placeholder=@"请确认支付密码";
        }
        else
        {
            //没有设置过支付密码
            self.pw1.placeholder=@"请输入登录密码";
            self.pw2.placeholder=@"请输入新的支付密码";
            self.pw3.placeholder=@"请确认支付密码";
        }
       
    }
    else
    {
        self.pw1.placeholder=@"请输入原登录密码";
        self.pw2.placeholder=@"请输入新登录密码";
        self.pw3.placeholder=@"请确认登录密码";
    }

    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//关闭键盘
-(void)handTap
{
    [self.pw1 resignFirstResponder];
    [self.pw2 resignFirstResponder];
    [self.pw3 resignFirstResponder];
}

//确认
- (IBAction)confirm:(id)sender
{
    if ([self.pw1.text isEqual:@""]||[self.pw2.text isEqual:@""]||[self.pw3.text isEqual:@""])
    {
        //提示用户将信息填写完整
        //提示用户，请求出错
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请将上述信息填写完整" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        if (![self.pw2.text isEqual:self.pw3.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"两次输入密码不相同" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if ([self.pw2.text isEqual:self.pw1.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"新密码不能与原密码相同" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            if (app.Rea_manager.reachable==YES)
            {
                if ([self.viewTitle_temp isEqual:@"登录密码"])
                {
                    //重新设置登录密码
                    //构造登录数据
                    NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",[self md5HexDigest:self.pw1.text],@"oldpass",[self md5HexDigest:self.pw3.text],@"newpass",nil];
                    //发送给服务器
                    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/updateLoginPwd.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                         
                         NSLog(@"denlu=%@",get_dic);
                         
                         if ([[get_dic objectForKey:@"state"] intValue]==1)
                         {
                             //密码修改成功--提示用户
                             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"登录密码修改成功" preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                   {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
                             [alert addAction:action];
                             [self presentViewController:alert animated:YES completion:nil];
                         }
                         else
                         {
                             //密码修改失败
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
                else if ([self.viewTitle_temp isEqual:@"支付密码"])
                {
                    //已经设置过支付密码
                    if ([self.flag intValue]==1)
                    {
                        //修改支付密码
                        //构造登录数据
                        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",[self md5HexDigest:self.pw1.text],@"oldpay",[self md5HexDigest:self.pw3.text],@"newpay",nil];
                        //发送给服务器
                        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/updatePayPwd.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                         {
                             NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                            
                             if ([[get_dic objectForKey:@"state"] intValue]==1)
                             {
                                 //密码修改成功--提示用户
                                 UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"支付密码修改成功" preferredStyle:UIAlertControllerStyleAlert];
                                 UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                       {
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                       }];
                                 [alert addAction:action];
                                 [self presentViewController:alert animated:YES completion:nil];
                                 
                             }
                             else
                             {
                                 //密码修改失败
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
                        //未设置过支付密码，则设置支付密码
                        //构造发送数据
                        NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",[self md5HexDigest:self.pw1.text],@"loginpass",[self md5HexDigest:self.pw3.text],@"paypass",nil];
                        //发送数据给服务器
                        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/setPayPwd.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                         {
                             NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                             
                            
                             
                             if ([[get_dic objectForKey:@"state"] intValue]==1)
                             {
                                 //密码修改成功--提示用户
                                 UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"支付密码设置成功" preferredStyle:UIAlertControllerStyleAlert];
                                 UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                       {
                                                           [self.delegate hasSetPW];
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                       }];
                                 [alert addAction:action];
                                 [self presentViewController:alert animated:YES completion:nil];
                                 
                             }
                             else
                             {
                                 //密码修改失败
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
                }
                
            }
            else
            {
                //如果网络未连接，提示用户
                //提示用户，检查网络
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
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
#pragma textField
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ((textField.tag==2)&&![textField.text isEqual:@""])
    {
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
    else if ((textField.tag==3)&&![textField.text isEqual:@""])
    {
        if (![textField.text isEqual:self.pw2.text])
        {
            //两次密码输入不一致，提示用户
            
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"两次密码输入不一致" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                textField.text=@"";
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];

        }
    }
}

@end
