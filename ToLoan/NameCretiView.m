//
//  NameCretiView.m
//  ToLoan
//
//  Created by jway on 15-4-28.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "NameCretiView.h"
#import "AppDelegate.h"
@interface NameCretiView ()
{
    
    AppDelegate*app;
}


@end

@implementation NameCretiView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //判断是否已经进行实名认证了
    //已经实名认证
    if ([[self.certi_dic objectForKey:@"isCrte"] intValue]==1)
    {
        //修饰
        self.hasCertiView.layer.cornerRadius=4.0f;
        self.hasCertiView.layer.borderWidth=1.0f;
        self.hasCertiView.layer.borderColor=[[UIColor brownColor] CGColor];
        //展示已认证信息，其余控件隐藏
        self.nameView.hidden=YES;
        self.idView.hidden=YES;
        self.nextStep.hidden=YES;
        self.idNum.text=[NSString stringWithFormat:@"%@",[self.certi_dic  objectForKey:@"idcard"]];
    }
    else
    {
        //如果未进行实名认证
        self.hasCertiView.hidden=YES;
        //指定协议
        self.nickname.delegate=self;
        self.cretiID.delegate=self;

        //修饰nameView外观
        self.nameView.layer.borderColor=[[UIColor grayColor] CGColor];
        self.nameView.layer.borderWidth=1.0f;
        self.nameView.layer.cornerRadius=4.0f;
        
        //修饰IDView外观
        self.idView.layer.borderColor=[[UIColor grayColor] CGColor];
        self.idView.layer.borderWidth=1.0f;
        self.idView.layer.cornerRadius=4.0f;

        //实例化程序委托类
        app=[UIApplication sharedApplication].delegate;
        
        //注册一个手势处理器，用来关闭键盘
        UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
        tap.numberOfTapsRequired=1;
        [self.view addGestureRecognizer:tap];
        
        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//单击关闭键盘
-(void)handTap
{
    [self.nickname resignFirstResponder];
    [self.cretiID resignFirstResponder];
}

//进行实名认证
- (IBAction)nextStep:(id)sender
{
    //如果有数据没填写，提示用户
    if ([self.nickname.text isEqual:@""]||[self.cretiID.text isEqual:@""])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请将上述信息填写完整"  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];

    }
    else
    {
        //身份证号的合法性验证放在这里
        //身份证号码验证
        NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
        NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
        if (![identityCardPredicate evaluateWithObject:self.cretiID.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"身份证号码格式错误"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                  {
                                      self.cretiID.text=nil;
                                  }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            if (app.Rea_manager.reachable==YES)
            {
                //构造发送数据
                NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"username",self.nickname.text,@"realname",self.cretiID.text,@"idcard",nil];
                //发送服务器
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/verifyRealName.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     if (operation.responseData)
                     {
                         NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                         
                         NSLog(@"get_dic=%@",get_dic);
                         
                         if ([[get_dic objectForKey:@"issuccess"] intValue]==1)
                         {
                             //如果成功，弹出提示框返回原来界面，并调用代理
                             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"实名认证成功" preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                                   {
                                                       [self.delegate hasNameCerti:self.cretiID.text];
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
                             
                             [alert addAction:action];
                             [self presentViewController:alert animated:YES completion:^{
                                 self.certi_dic=nil;
                             }];
                         }
                         else
                         {
                             //提示用户，认证失败
                             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                             [alert addAction:action];
                             [self presentViewController:alert animated:YES completion:nil];
                         }
                     }
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     
                 }];

            }
            else
            {
                //提示用户，请求出错
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
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
#pragma delegae
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //输入格式校验
    if ((textField.tag==1)&&![textField.text isEqual:@""])
    {
        //名字只能包含中文的字符串
        NSString*format=@"^[\u4e00-\u9fa5]+$";
        NSPredicate*textTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",format];
        if(![textTest evaluateWithObject:textField.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"真实姓名应由中文字符组成"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
            {
                textField.text=nil;
            }];

            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else
    {
        if ((textField.text.length!=18)&&![textField.text isEqual:@""])
        {
            //身份证号码验证
            NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
            NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
            if (![identityCardPredicate evaluateWithObject:textField.text])
            {
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"身份证号码格式错误"  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                      {
                                          textField.text=nil;
                                      }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
        
        }
    }
}

@end
