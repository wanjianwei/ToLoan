//
//  itemDetailView.m
//  ToLoan
//
//  Created by jway on 15-4-22.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "itemDetailView.h"
#import "PayCashView.h"
#import "AppDelegate.h"

@interface itemDetailView ()
{
    //定义一个按钮，功能为“计算收益”
    UIButton*bt;
    //定义一个输入框
    UITextField*field;
    //定义一个flag,用于检测是否点击了“计算收益”按钮
    int flag;
    //定义一个NSDictionary，用来存放点击“计算收益”按钮后服务器返回的收益信息
    NSDictionary*income_dic;
    //定义一个字典，用来保存“点击计算收益后”服务器返回的所有数据
    NSDictionary*get_dic_temp;
    //定义一个NSString来存储可用余额
    NSString*balance;
    
    //定义一个缓存，用来存储输入金额
    NSString*money_num;
    //定义一个程序代理
    AppDelegate*app;
}

@end

@implementation itemDetailView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理
    self.detailTable.dataSource=self;
    self.detailTable.delegate=self;
    //修改按钮外观
    self.nextStep.layer.cornerRadius=4.0f;
    
    //定义一个手势处理器，用来关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    //实例化程序代理
    app=[UIApplication sharedApplication].delegate;
    //开一个线程，来获取可用余额
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
                   {
                       //获取可用余额
                       [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getAccountInfo.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
                        {
                            if (operation.responseData!=nil)
                            {
                                //获取数据
                                NSDictionary*get_dic1=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                                
                                //在主线程上更新数据
                                dispatch_async(dispatch_get_main_queue(), ^
                                               {
                                                   balance=[NSString stringWithFormat:@"%@元",[get_dic1 objectForKey:@"balance"]];
                                                   //要重新载入数据
                                                   [self.detailTable reloadData];
                                               });
                            }
                        }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                        {
                            ////提示用户，请求出错
                            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"获取可用余额信息出错，请检查网络连接状况" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:action];
                            [self presentViewController:alert animated:YES completion:nil];
                        }];
                       
                   });
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}


//点击背景，关闭键盘
-(void)handTap
{
    [field resignFirstResponder];
}

//跳转到支付页面
- (IBAction)nextStep:(id)sender
{
    //如果小于起投金额或是大于可投金额，则弹出提示
    if ([field.text intValue]<[[self.get_dic objectForKey:@"minbuy"] intValue]||[field.text intValue]>([[self.get_dic objectForKey:@"ptotal"] intValue]-[[self.get_dic objectForKey:@"comp"] intValue]))
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"投资金额应当大于起投金额并小于可投金额" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([field.text intValue]>[balance intValue])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"投资金额应当小于可用余额" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
       //直接跳到下一个视图--支付视图，并将投资金额传递给下一个模块
        UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PayCashView*view1=[main instantiateViewControllerWithIdentifier:@"paycash"];
        //此处设立一个标志，表明这是来自于“投资项目”，区别于“提现”
        
        view1.flag=[NSNumber numberWithInt:1];
        //将投资金额传送给下一个视图
        view1.money_num=field.text;
        
        //将项目pid传递下去
        view1.itempid=self.itempid;
        
        view1.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:view1 animated:YES completion:nil];
    }
}

#pragma delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //定义一个整型数据，用来存放每节行的个数
   
    if (section==0)
        return 1;
    else if (section==1)
        return 4;
    else if (section==2)
        return 3;
    else
    {
        if (flag==1)
            return 3;
        else
            return 1;
    }
  
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identy];
    
    //配置cell
    if (indexPath.section==0)
    {
        cell.textLabel.text=@"用户名:";
        cell.textLabel.textColor=[UIColor grayColor];
        cell.detailTextLabel.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        cell.detailTextLabel.textColor=[UIColor redColor];
    }
    else if (indexPath.section==1)
    {
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"项目名称:";
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.text=[self.get_dic objectForKey:@"pname"];
            cell.detailTextLabel.textColor=[UIColor redColor];
        }
        else if (indexPath.row==1)
        {
            cell.textLabel.text=@"预期年化利率:";
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.text=[self.get_dic objectForKey:@"interest"];
            cell.detailTextLabel.textColor=[UIColor redColor];
        }
        else if (indexPath.row==2)
        {
            cell.textLabel.text=@"起息日期:";
            cell.textLabel.textColor=[UIColor grayColor];
            
            //设置日期格式
            NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            //将起息日转为NSDate形式
            NSDate*date1=[NSDate dateWithTimeIntervalSince1970:[[self.get_dic objectForKey:@"gitime"] integerValue]];
            cell.detailTextLabel.text=[formatter stringFromDate:date1];
        }
        else
        {
            cell.textLabel.text=@"回款日期:";
            cell.textLabel.textColor=[UIColor grayColor];
            
            //设置日期格式
            NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            //将起息日转为NSDate形式
            NSDate*date2=[NSDate dateWithTimeIntervalSince1970:[[self.get_dic objectForKey:@"capitalTime"] integerValue]];
            cell.detailTextLabel.text=[formatter stringFromDate:date2];
        }
    }
    else if (indexPath.section==2)
    {
        ///////////可用余额如何获取不知道
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"可用余额:";
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.text=balance;
        }
        else if (indexPath.row==1)
        {
            cell.textLabel.text=@"起投金额:";
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[self.get_dic objectForKey:@"minbuy"]];
            cell.detailTextLabel.textColor=[UIColor redColor];
        }
        else
        {
            cell.textLabel.text=@"可投金额:";
            cell.textLabel.textColor=[UIColor grayColor];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%d元",[[self.get_dic objectForKey:@"ptotal"] intValue]-[[self.get_dic objectForKey:@"comp"] intValue]];
            cell.detailTextLabel.textColor=[UIColor redColor];
        }
    }
    else
    {
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"投资金额:";
            cell.textLabel.textColor=[UIColor grayColor];
            //添加输入框--输入投资金额
            field=[[UITextField alloc] initWithFrame:CGRectMake(115, 5, 120, 30)];
            //修饰field的外观
            field.layer.borderWidth=1.0f;
            field.layer.borderColor=[[UIColor grayColor] CGColor];
            field.keyboardType=UIKeyboardTypeNumberPad;
            //判断金额输入框的值
            if (money_num!=nil)
            {
                field.text=money_num;
            }
            else
                field.placeholder=@"单位为:元";
            //指定协议代理
            field.delegate=self;
            
            [cell addSubview:field];
            //添加“计算收益”按钮
            bt=[[UIButton alloc] initWithFrame:CGRectMake(245, 5, 60, 30)];
            //修饰按钮外观属性
            [bt setTitle:@"计算收益" forState:UIControlStateNormal];
            [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [bt setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            bt.titleLabel.font=[UIFont boldSystemFontOfSize:10];
            bt.backgroundColor=[UIColor groupTableViewBackgroundColor];
            bt.layer.cornerRadius=2.0f;

            //定义事件响应
            [bt addTarget:self action:@selector(countIncome) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:bt];
        }
        else if (indexPath.row==1)
        {
            //自定义总收益标题
            UILabel*lab_income=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 44)];
            lab_income.textColor=[UIColor blackColor];
            lab_income.textAlignment=NSTextAlignmentRight;
            lab_income.text=@"投资到期可获得总收益:";
            lab_income.font=[UIFont boldSystemFontOfSize:15];
            [cell addSubview:lab_income];
            
            //自定义总收益label
            UILabel*lab_1=[[UILabel alloc] initWithFrame:CGRectMake(200, 0, 100, 44)];
            lab_1.textColor=[UIColor redColor];
            lab_1.textAlignment=NSTextAlignmentCenter;
            lab_1.text=[NSString stringWithFormat:@"%@元",[get_dic_temp objectForKey:@"getTotalMoney"]];
            [cell.contentView addSubview:lab_1];
        }
        else
        {
            //标题
            UILabel*returnDate1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width/3, 30)];
            returnDate1.textAlignment=NSTextAlignmentCenter;
            returnDate1.textColor=[UIColor blackColor];
            returnDate1.font=[UIFont boldSystemFontOfSize:12];
            returnDate1.text=@"还款日";
            [cell.contentView addSubview:returnDate1];
            
            //对应取值label
            UILabel*retunData_1=[[UILabel alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width/3, 30)];
            retunData_1.textAlignment=NSTextAlignmentCenter;
            retunData_1.textColor=[UIColor blackColor];
            retunData_1.font=[UIFont boldSystemFontOfSize:12];
            
            NSDate*date=[NSDate dateWithTimeIntervalSince1970:[[income_dic objectForKey:@"date"] integerValue]];
            NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            //取值来源于服务器
            retunData_1.text=[formatter stringFromDate:date];
            [cell.contentView addSubview:retunData_1];
            
            //标题
            UILabel*returnDate2=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, 0,[UIScreen mainScreen].bounds.size.width/3, 30)];
            returnDate2.textAlignment=NSTextAlignmentCenter;
            returnDate2.textColor=[UIColor blackColor];
            returnDate2.font=[UIFont boldSystemFontOfSize:12];
            returnDate2.text=@"应收本金";
            [cell.contentView addSubview:returnDate2];
            
            //对应取值label
            UILabel*retunData_2=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, 30, [UIScreen mainScreen].bounds.size.width/3, 30)];
            retunData_2.textAlignment=NSTextAlignmentCenter;
            retunData_2.textColor=[UIColor blackColor];
            retunData_2.font=[UIFont boldSystemFontOfSize:12];
            
            //取值来源于服务器
            retunData_2.text=[NSString stringWithFormat:@"%@元",[income_dic objectForKey:@"principal"]];
            retunData_2.textColor=[UIColor redColor];
            [cell.contentView addSubview:retunData_2];
            
            
            //标题
            UILabel*returnDate3=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*2/3, 0,[UIScreen mainScreen].bounds.size.width/3, 30)];
            returnDate3.textAlignment=NSTextAlignmentCenter;
            returnDate3.textColor=[UIColor blackColor];
            returnDate3.font=[UIFont boldSystemFontOfSize:12];
            returnDate3.text=@"应收利息";
            [cell.contentView addSubview:returnDate3];
            
            //对应取值label
            UILabel*retunData_3=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, 30, [UIScreen mainScreen].bounds.size.width, 30)];
            retunData_3.textAlignment=NSTextAlignmentCenter;
            retunData_3.textColor=[UIColor blackColor];
            retunData_3.font=[UIFont boldSystemFontOfSize:12];
            
            //取值来源于服务器
            retunData_3.text=[NSString stringWithFormat:@"%@元",[income_dic objectForKey:@"interest"]];
            retunData_3.textColor=[UIColor redColor];
            [cell.contentView addSubview:retunData_3];
        }
       
    }
    
    cell.textLabel.font=[UIFont boldSystemFontOfSize:14];
    cell.detailTextLabel.font=[UIFont boldSystemFontOfSize:14];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==3)
        return 25;
    else
        return 15;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3)
    {
        if (indexPath.row==0)
            return 44;
        else if (indexPath.row==1)
            return 44;
        else
            return 60;
    }
    else
        return 44;
}

//表足视图
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section==3)
    {
        UIView*footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 25)];
        
        UILabel*lab1=[[UILabel alloc] initWithFrame:CGRectMake(50, 0, 50, 25)];
        lab1.font=[UIFont boldSystemFontOfSize:9];
        lab1.textColor=[UIColor redColor];
        lab1.textAlignment=NSTextAlignmentRight;
        lab1.text=@"温馨提示:";
        [footView addSubview:lab1];
        
        UILabel*lab2=[[UILabel alloc] initWithFrame:CGRectMake(105, 0, 170, 25)];
        lab2.textColor=[UIColor grayColor];
        lab2.text=@"平台将收取总收益的0.5%作为风险保证金";
        lab2.textAlignment=NSTextAlignmentLeft;
        lab2.font=[UIFont boldSystemFontOfSize:9];
        [footView addSubview:lab2];
        return footView;
    }
    else
        return nil;
    
}

#pragma UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.detailTable setContentOffset:CGPointMake(0, 160) animated:YES];
    field.placeholder=@"";
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.detailTable setContentOffset:CGPointMake(0, 0) animated:YES];
    if ([field.text isEqual:@""])
    {
        field.placeholder=@"单位为元";
    }
}

//点击“计算收益”按钮,弹出收益提示框

-(void)countIncome
{

    if (![field.text isEqual:@""])
    {
        
        //如果小于起投金额或是大于可投金额，则弹出提示
        if ([field.text intValue]<[[self.get_dic objectForKey:@"minbuy"] intValue]||[field.text intValue]>([[self.get_dic objectForKey:@"ptotal"] intValue]-[[self.get_dic objectForKey:@"comp"] intValue]))
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"投资金额应当大于起投金额并小于可投金额" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if ([field.text intValue]>[balance intValue])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"投资金额应当小于可用余额" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
           
            //判断网络是否可连接
            if (app.Rea_manager.reachable==YES)
            {
                //先构造请求数据
                NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:field.text,@"money",self.itempid,@"pid", nil];
                
                //向服务器发送数据
                [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInterestByMoney.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
                 {
                     //返回数据成功
                     get_dic_temp=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     
                     income_dic=[[get_dic_temp objectForKey:@"receipt"] objectAtIndex:0];
                     
                     //将标志设置为1，并向服务器发送数据
                     flag=1;
                     //并将输入金额存入缓存
                     money_num=field.text;
                     
                     //重新加载tableView
                     [self.detailTable reloadData];
                 }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                 {
                     UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络或服务器出现异常" preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                     [alert addAction:action];
                     [self presentViewController:alert animated:YES completion:nil];
                 }];
            }
            else
            {
                //提示用户打开网络
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
           
            
        }
        
    }
    else
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请先填写投资金额" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
    
}

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        //注销这些数据，释放内存
        income_dic=nil;
        get_dic_temp=nil;
    }];
}
@end
