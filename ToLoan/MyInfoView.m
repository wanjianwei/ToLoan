//
//  MyInfoView.m
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "MyInfoView.h"
#import "AppDelegate.h"
#import "NameCretiView.h"
#import "CardCertiView.h"
#import "PhoneCertiView.h"
#import "PasswordCerti.h"
#import "BankCertiSucView.h"
#import "FinishbankCertiView.h"
@interface MyInfoView ()
{
   //定义一个程序委托类
    AppDelegate*app;
    //定义一个数组用来存放服务器返回的数据
    NSDictionary*get_dic;
    //定义一个故事版引用
    UIStoryboard*main;
    
    //定义一个活动指示器
     UIActivityIndicatorView*activityView;
}

@end

@implementation MyInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理
    self.info_list.dataSource=self;
    self.info_list.delegate=self;
    self.info_list.scrollEnabled=NO;
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    //实例化故事版引用
    main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
   //注册接受通知，为的是即使更新银行卡绑定信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBank:) name:@"bankNumChecked" object:nil];
    
    
   //更新银行卡解绑定信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:@"moveBindNot" object:nil];
    
    //更新银行卡认证成功消息
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:@"updateState" object:nil];
   
    
    //定义一个活动指示器
    activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    //将tableView的可交互性去掉
    self.info_list.userInteractionEnabled=NO;
    
    //向服务器请求数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getVerifyInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //数据返回成功
        if (operation.responseData)
        {
            get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
            //表视图重新加载
            [self.info_list reloadData];
            
            //成功了活动指示器消失
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            //恢复tableView的可交互性
            self.info_list.userInteractionEnabled=YES;
        }
    }
     
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
        //成功了活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        
        //恢复tableView的可交互性
        self.info_list.userInteractionEnabled=YES;
        //请求服务器失败，返回错误提示
        //提示用户，请求出错
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"访问服务器出现错误" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }];
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

#pragma UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


//配置cell格式
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
    if (indexPath.row==0)
    {
        cell.imageView.image=[UIImage imageNamed:@"4_1_1.png"];
        cell.textLabel.text=@"手机认证";
        
        //是否已认证，由服务器返回的数据决定
        if ([[[get_dic objectForKey:@"phone"] objectForKey:@"isCrte"] intValue]==1)
            cell.detailTextLabel.text=@"已认证";
        else
            cell.detailTextLabel.text=@"未认证";
        
    }
    else if (indexPath.row==1)
    {
        cell.imageView.image=[UIImage imageNamed:@"certi_user@2x.png"];
        cell.textLabel.text=@"实名认证";
        
        //验证信息来源于服务器
        if ([[[get_dic objectForKey:@"user"] objectForKey:@"isCrte"] intValue]==1)
            cell.detailTextLabel.text=@"已认证";
        else
            cell.detailTextLabel.text=@"未认证";
        
    }
    else if (indexPath.row==2)
    {
        cell.imageView.image=[UIImage imageNamed:@"6_2_1.png"];
        cell.textLabel.text=@"银行卡认证";
        
        //验证信息来源于服务器
        if ([[[get_dic objectForKey:@"bank"] objectForKey:@"isCrte"] intValue]==1)
            cell.detailTextLabel.text=@"已认证";
        else
            cell.detailTextLabel.text=@"未认证";
        
    }
    else if (indexPath.row==3)
    {
        cell.imageView.image=[UIImage imageNamed:@"certi_password@2x.png"];
        cell.textLabel.text=@"支付密码";
        //验证信息来源于服务器
        if ([[get_dic objectForKey:@"isSetPay"] intValue]==1)
            cell.detailTextLabel.text=@"修改";
        else
            cell.detailTextLabel.text=@"未设置";
        
    }
    else
    {
        cell.imageView.image=[UIImage imageNamed:@"certi_password@2x.png"];
        cell.textLabel.text=@"登录密码";
    }
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
       //跳转到手机认证界面
        PhoneCertiView*phoneView=[main instantiateViewControllerWithIdentifier:@"phonecerti"];
        phoneView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        //设置自己的代理
        phoneView.delegate=self;
        phoneView.certi_dic=[get_dic objectForKey:@"phone"];
        [self presentViewController:phoneView animated:YES completion:nil];
        
    }
    else if (indexPath.row==1)
    {
        //调转到实名认证的界面
        NameCretiView*nameView=[main instantiateViewControllerWithIdentifier:@"namecreti"];
        nameView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        //设置代理
        nameView.delegate=self;
        nameView.certi_dic=[get_dic objectForKey:@"user"];
        [self presentViewController:nameView animated:YES completion:nil];
    }
    else if (indexPath.row==2)
    {
        //跳转到银行卡认证界面
        //先确定用户是否进行了实名认证
        if ([[[get_dic objectForKey:@"user"] objectForKey:@"isCrte"] intValue]==0)
        {
            //如果没有进行实名认证，则提示用户先进行实名认证
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请先进行实名认证" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        //用户已经进行实名认证
        else
        {
            //判断用户是否认证成功
            //用户未认证
            if([[[get_dic objectForKey:@"bank"] objectForKey:@"isCrte"] intValue]==0)
            {
                if ([[[get_dic objectForKey:@"bank"] objectForKey:@"card"] longLongValue]!=0)
                {
                    //银行卡已经绑定，直接跳到认证页面
                    FinishbankCertiView*finishView=[main instantiateViewControllerWithIdentifier:@"finishcerti"];
                    finishView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:finishView animated:YES completion:nil];
                    
                }
                else
                {
                    //银行卡未认证也未绑定
                    CardCertiView*cardView=[main instantiateViewControllerWithIdentifier:@"cardcerti"];
                    cardView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:cardView animated:YES completion:nil];
                }
               
            }
            //用户已经认证成功
            else
            {
                //跳转到认证成功界面,并传递认证银行卡号
                BankCertiSucView*sucView=[main instantiateViewControllerWithIdentifier:@"banksuc"];
                sucView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                //把银行卡号传递下去
                sucView.cardID=[NSString stringWithFormat:@"%@",[[get_dic objectForKey:@"bank"] objectForKey:@"card"]];
                [self presentViewController:sucView animated:YES completion:nil];
                
            }
        }
        
    }
    
    else
    {
        //跳转到登录密码和支付密码修改界面
        PasswordCerti*pwView=[main instantiateViewControllerWithIdentifier:@"pwcerti"];
        //在此处要把标题传过去
        if (indexPath.row==3)
        {
            pwView.viewTitle_temp=@"支付密码";
            //将“支付密码”的当前设置状态发送给下一个模块
            pwView.flag=[get_dic objectForKey:@"isSetPay"];
        }
        else
            pwView.viewTitle_temp=@"登录密码";
        
        pwView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        //设置自己的代理
        pwView.delegate=self;
        
        [self presentViewController:pwView animated:YES completion:nil];
    }
}

#pragma certiProtocol

//已经进行实名认证
-(void)hasNameCerti:(NSString*)certiID
{
    //实名认证后，认证状态和身份证号要更新
    [[get_dic objectForKey:@"user"] setObject:[NSNumber numberWithInt:1] forKey:@"isCrte"];
    [[get_dic objectForKey:@"user"] setObject:certiID forKey:@"idcard"];
    [self.info_list reloadData];
}
//已经进行电话认证
-(void)hasPhoneCerti:(NSString *)phoneNum
{
    //电话认证后，认证状态和电话要更新
    [[get_dic objectForKey:@"phone"] setObject:[NSNumber numberWithInt:1] forKey:@"isCrte"];
    [[get_dic objectForKey:@"phone"] setObject:phoneNum forKey:@"phoneNum"];
    [self.info_list reloadData];
}
//已经设置了支付密码
-(void)hasSetPW
{
    //将支付密码设置状态设置为1；
    [get_dic setValue:[NSNumber numberWithInt:1] forKey:@"isSetPay"];
    [self.info_list reloadData];
}

//已经进行了银行卡验证
-(void)hasBankNumCerti:(NSDictionary *)dic
{
    //dic中传递的时认证状态和银行卡号
    //更新认证状态
    [[get_dic objectForKey:@"bank"] setObject:[dic objectForKey:@"state"] forKey:@"isCrte"];
    //更新银行卡号
    [[get_dic objectForKey:@"bank"] setObject:[dic objectForKey:@"cardNo"] forKey:@"card"];
    
    //重载数据
    [self.info_list reloadData];
    
}


//通过接受通知，更新银行卡号，这通知是由银行卡号认证第二步发出的，--绑定银行卡号

-(void)updateBank:(NSNotification*)noti
{
    //更新银行卡号，表示已经绑定了银行卡号
    [[get_dic objectForKey:@"bank"] setObject:[[noti userInfo] objectForKey:@"cardID"] forKey:@"card"];
    [self.info_list reloadData];
    
}


//更新银行卡认证信息
-(void)updateState:(NSNotification*)noti
{
    //更新认证状态，更新银行卡号
    [[get_dic objectForKey:@"bank"] setObject:[[noti userInfo] objectForKey:@"state"] forKey:@"isCrte"];
    [[get_dic objectForKey:@"bank"] setObject:[[noti userInfo] objectForKey:@"cardID"] forKey:@"card"];
    [self.info_list reloadData];
}
@end
