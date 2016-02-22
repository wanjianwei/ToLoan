//
//  CardCertiView.m
//  ToLoan
//
//  Created by jway on 15-4-28.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "CardCertiView.h"
#import "CheckCardInfoView.h"
#import "AppDelegate.h"
#import "ChoseBankView.h"
@interface CardCertiView ()
{
    //定义一个程序委托
    AppDelegate*app;
    //存储银行id
    NSNumber*bankid;
}

@end

@implementation CardCertiView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设定按钮外观
    self.chosebank.layer.borderWidth=1.0f;
    self.chosebank.layer.borderColor=[[UIColor blueColor] CGColor];
    self.chosebank.layer.cornerRadius=4.0f;
    self.chosebank.titleLabel.textAlignment=NSTextAlignmentRight;
    
    //设置bgView的外观
    self.bgView.layer.borderWidth=1.0f;
    self.bgView.layer.borderColor=[[UIColor blueColor] CGColor];
    self.bgView.layer.cornerRadius=4.0f;
    
    //设定开户者姓名
    self.nickname.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    //注册手势处理器关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
    //实例化
    app=[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//关闭键盘
-(void)handTap
{
    [self.bankNum resignFirstResponder];
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//选择银行按钮
- (IBAction)choseBank:(id)sender
{
    //如果可以上网
    if (app.Rea_manager.reachable==YES)
    {
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChoseBankView*choseView=[main instantiateViewControllerWithIdentifier:@"bankchose"];
        //指定自己的代理
        choseView.delegate=self;
        choseView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:choseView animated:YES completion:nil];

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

//下一次操作
- (IBAction)nextStep:(id)sender
{
    //在此处进行输入合法性验证
    if (![self.bankNum.text isEqual:@""])
    {
        //判断银行卡是否符合格式
        if (![self isValidCardNumber:self.bankNum.text])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"银行卡输入不合法" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        else
        {
            //跳转到下一个界面，要把所选择的银行和卡号,以及银行id传递到下一个视图
            UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CheckCardInfoView*view=[main instantiateViewControllerWithIdentifier:@"checkcard"];
            //银行名称
            view.bakName_temp=self.chosebank.titleLabel.text;
            //银行卡号
            view.cardID=self.bankNum.text;
            //把银行的id传给下一个视图
            view.bankid=bankid;
            view.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            [self presentViewController:view animated:YES completion:nil];
            
        }
    }
    else
    {
        //如果银行号未填
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请先输入银行卡号" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];

    }
}


//银行卡合法性检验
-(BOOL)isValidCardNumber:(NSString *)cardNumber
{
    NSString *digitsOnly =cardNumber;
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = false;
    for (int i =(int)digitsOnly.length - 1; i >= 0; i--)
    {
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo)
        {
            addend = digit * 2;
            if (addend > 9)
           {
            addend -= 9;
           }
        }
        else
        {
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    int modulus = sum % 10;
    return modulus == 0;
}

#pragma certiProtocol

-(void)hasFinishChose:(UIImage *)image With:(NSDictionary *)text
{
    //存下图片
    self.banklogo.image=image;
    //设置按钮得到标题为银行的名字
    [self.chosebank setTitle:[text objectForKey:@"name"] forState:UIControlStateNormal];
    
    //存下银行的id
    bankid=[text objectForKey:@"id"];
}

@end
