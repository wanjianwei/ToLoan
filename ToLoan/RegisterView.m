//
//  RegisterView.m
//  ToLoan
//
//  Created by jway on 15-4-22.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "RegisterView.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
@interface RegisterView ()
{
    //定义一个委托程序代理
    AppDelegate*app;
    
    //定义一个输入框，用来输入用户名
    UITextField*username;
    
    //输入电话
    UITextField*telPhone;
    //输入密码
    UITextField*password;
    //密码验证
    UITextField*checkPW;
    //输入邀请码
    UITextField*inviteCode;
}

@end

@implementation RegisterView

//用户名，防止表视图上下移动时，用户名丢失
NSString*username_temp=@"";

//手机号，同理
NSString*telPhone_temp=@"";


- (void)viewDidLoad {
    [super viewDidLoad];
    //指定协议代理
    self.registerPart.dataSource=self;
    self.registerPart.delegate=self;
    //设置外观
    self.registerPart.backgroundColor=[UIColor clearColor];
    self.registerPart.scrollEnabled=NO;
    
    //注册一个手势处理器，用来关闭键盘
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


//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//关闭键盘
-(void)handTap
{
    [(UITextField*)[self.view viewWithTag:1] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:2] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:3] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:4] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:5] resignFirstResponder];
}

//注册
-(void)register_now
{
    //对输入框进行合法性检测---用户名
    if(![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^[A-Z0-9a-z_]{6,24}+$"]] evaluateWithObject:username.text])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"用户名格式不符合要求" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                              {
                                  //不合法的输入清空
                                  username.text=@"";
                              }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
     //对手机号进行合法性验证
    else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,1，5-9]))\\d{8}$"]] evaluateWithObject:telPhone.text])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"电话号码不合法" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                              {
                                  //不合法的输入清空
                                  telPhone.text=@"";
                              }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //新的密码
    else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",[NSString stringWithFormat:@"^[A-Z0-9a-z]{6,24}+$"]] evaluateWithObject:password.text])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"新密码格式不符合要求" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                              {
                                  //不合法的输入清空
                                  password.text=@"";
                              }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (![checkPW.text isEqual:password.text])
    {
        
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"两次密码输入不一致" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                              {
                                  //不合法的输入清空
                                  checkPW.text=@"";
                              }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        //如果网络连接正常
        if (app.Rea_manager.reachable==YES)
        {
            //定义一个活动指示器
            UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
            [self.view addSubview:activityView];
            [activityView startAnimating];
            //构造发送数据
            NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:username.text,@"username",[self md5HexDigest:password.text], @"password",telPhone.text,@"phone",inviteCode.text,@"invitecode",nil];
            //向服务器请求数据
            [app.manager POST:@"http://www.xiangnidai.com/dcs/app/register.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 
                 //活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 if (operation.responseData)
                 {
                     NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     
                     //注册成功
                     if ([[get_dic objectForKey:@"state"] intValue]==1)
                     {
                         //注册成功，弹出提示，并返回登录
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"恭喜！" message:@"注册成功,将返回登录页面" preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                               
                                               {
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }];
                         
                         [alert addAction:action];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
                     else
                     {
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errormsg"] preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                         [alert addAction:action];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
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
            //提示用户，查看网络连接状态
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络罗已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}
#pragma UITableViewDelegate/DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
   
    if (indexPath.section!=5)
    {
        cell.layer.borderWidth=1.0f;
        cell.layer.borderColor=[[UIColor grayColor] CGColor];
    }
    
    //配置cell
    if (indexPath.section==0)
    {
        cell.imageView.image=[UIImage imageNamed:@"project_star_hilite.png"];
        //添加一个输入框
        username=[[UITextField alloc] initWithFrame:CGRectMake(60, 2, 250, 40)];
        username.textColor=[UIColor grayColor];
        //指定协议代理及tag，便于引用
        username.delegate=self;
        username.tag=1;
        username.font=[UIFont boldSystemFontOfSize:17];
       //防止因为视图上下滑动而丢失数据
        if (![username_temp isEqual:@""])
            username.text=username_temp;
        else
            username.placeholder=@"请输入您的用户名";
        [cell addSubview:username];
        return cell;
    }
    else if (indexPath.section==1)
    {
        cell.imageView.image=[UIImage imageNamed:@"project_star_hilite.png"];
        //添加一个输入框
        telPhone=[[UITextField alloc] initWithFrame:CGRectMake(60, 2, 250, 40)];
        telPhone.textColor=[UIColor grayColor];
        //指定协议代理及tag，便于引用
        telPhone.delegate=self;
        telPhone.font=[UIFont boldSystemFontOfSize:17];
        if (![telPhone_temp isEqual:@""])
            telPhone.text=telPhone_temp;
        else
            telPhone.placeholder=@"请输入您的手机号";
        telPhone.keyboardType=UIKeyboardTypeNumberPad;
        telPhone.tag=2;
        [cell addSubview:telPhone];
        return cell;
    }
    else if (indexPath.section==2)
    {
        cell.imageView.image=[UIImage imageNamed:@"project_star_hilite.png"];
        //添加一个输入框
       password=[[UITextField alloc] initWithFrame:CGRectMake(60, 2, 250, 40)];
       password.textColor=[UIColor grayColor];
        //指定协议代理及tag，便于引用
        password.delegate=self;
        password.tag=3;
        password.font=[UIFont boldSystemFontOfSize:17];
        password.placeholder=@"请输入您的密码";
        password.secureTextEntry=YES;
        
      //  password.clearsOnBeginEditing=YES;
        [cell addSubview:password];
        return cell;
    }
    else if (indexPath.section==3)
    {
        cell.imageView.image=[UIImage imageNamed:@"project_star_hilite.png"];
        //添加一个输入框
        checkPW=[[UITextField alloc] initWithFrame:CGRectMake(60, 2, 250, 40)];
        checkPW.textColor=[UIColor grayColor];
        //指定协议代理及tag，便于引用
        checkPW.delegate=self;
        checkPW.tag=4;
        checkPW.font=[UIFont boldSystemFontOfSize:17];
        checkPW.placeholder=@"请再次输入您的密码";
        checkPW.secureTextEntry=YES;
      //  checkPW.clearsOnBeginEditing=YES;
        [cell addSubview:checkPW];
        return cell;
    }
    else if (indexPath.section==4)
    {
        //cell.imageView.image=[UIImage imageNamed:@"register_user.png"];
        //添加一个输入框
        inviteCode=[[UITextField alloc] initWithFrame:CGRectMake(10, 2, 280, 40)];
        inviteCode.textColor=[UIColor grayColor];
        //指定协议代理及tag，便于引用
        inviteCode.delegate=self;
        inviteCode.tag=5;
        inviteCode.font=[UIFont boldSystemFontOfSize:17];
        inviteCode.placeholder=@"请输入邀请人手机号/用户名";
     //   inviteCode.clearsOnBeginEditing=YES;
        [cell addSubview:inviteCode];
        return cell;
    }
    else
    {
        UIButton*bt=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width-40, 44)];
        bt.backgroundColor=[UIColor blueColor];
        bt.opaque=0.6;
        [bt setTitle:@"立即注册" forState:UIControlStateNormal];
        //当按钮处于highLight状态时，颜色要变一下
        [bt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [bt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        bt.layer.cornerRadius=4.0f;
        //添加事件响应
        [bt addTarget:self action:@selector(register_now) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:bt];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return 30;
    else
        return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView*footerView=[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 20)];
    if (section==0)
    {
        UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 20)];
        lab.text=@"6~24个字符，字母开头，字母、数字、下划线组成";
        lab.textColor=[UIColor grayColor];
    
        lab.font=[UIFont boldSystemFontOfSize:10];
        [footerView addSubview:lab];
        footerView.backgroundColor=[UIColor clearColor];
        return footerView;
    }
    else if (section==2)
    {
        UILabel*lab=[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 300, 20)];
        lab.text=@"6~24个字符，字母、数字组成,区分大小写";
        lab.textColor=[UIColor grayColor];
    
        lab.font=[UIFont boldSystemFontOfSize:11];
        [footerView addSubview:lab];
        footerView.backgroundColor=[UIColor clearColor];
        return footerView;
    }
    else
        return footerView;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, 30)];
}

#pragma UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    //输入合法性验证
    if (textField.tag==1)
    {
        //把用户名存下来，防止tableView移动时，数据丢失；
        username_temp=textField.text;
        //首先长度要符合要求
        if (![textField.text isEqual:@""])
        {
            //匹配由数字、字母、下划线组成的字符串
            NSString*format=@"^[A-Z0-9a-z_]{6,24}+$";
            NSPredicate*textTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",format];
            if(![textTest evaluateWithObject:textField.text])
            {
               UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"用户名格式不符合要求" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                {
                    //不合法的输入清空
                    textField.text=@"";
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        
    }
    else if (textField.tag==2)
    {
        //将电话号码存储
        telPhone_temp=textField.text;
        //手机号码应该为11位数字
        if(![textField.text isEqual:@""])
        {
            NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,1，5-9]))\\d{8}$";
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            if (![pred evaluateWithObject:textField.text])
            {
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"电话号码不合法" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                {
                    //不合法的输入清空
                    textField.text=@"";
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            
        }
    
    }
    else if (textField.tag==3&&![textField.text isEqual:@""])
    {
          //首先长度要符合要求
          //匹配由数字、字母组成的字符串
          NSString*format=@"^[A-Z0-9a-z]{6,24}+$";
          NSPredicate*textTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",format];
          if(![textTest evaluateWithObject:textField.text])
         {
             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"用户密码格式不符合要求"  preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
             {
                 //不合法的输入清空
                 textField.text=@"";
             }];
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];
         }
    }
    else if (textField.tag==4&&![textField.text isEqual:@""])
    {
        if (![textField.text isEqual:[(UITextField*)[self.view viewWithTag:3] text]])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"两次密码输入不匹配" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                //不合法的输入清空
                textField.text=@"";
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        //表视图恢复状态
        [self.registerPart setContentOffset:CGPointMake(0, 0)];
    }
    else
    {
        [self.registerPart setContentOffset:CGPointMake(0, 0)];
        
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag==5)
    {
        [self.registerPart setContentOffset:CGPointMake(0, 180)];
    }
    else if (textField.tag==4)
        [self.registerPart setContentOffset:CGPointMake(0, 80)];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [(UITextField*)[self.view viewWithTag:1] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:2] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:3] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:4] resignFirstResponder];
    [(UITextField*)[self.view viewWithTag:5] resignFirstResponder];
    return YES;
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
