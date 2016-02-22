//
//  UserCentreView.m
//  ToLoan
//
//  Created by jway on 15-4-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "UserCentreView.h"
#import "MyInfoView.h"
#import "PropertyManageView.h"
#import "SetUpView.h"
#import "AppDelegate.h"
#import "MyInvestView.h"
#import "GetCashView.h"
#import "MyNoticeView.h"
#import "TopUpView.h"
@interface UserCentreView ()
{
    //定义一个label，用来存储奖励的金额
    UILabel*lab;
    //定义一个label。用来存储今日收益
    UILabel*lab1;
    
    //定义一个label，用来存储待接收总金额
    UILabel*lab2;
    //定义一个label，用来存储本月收益
    UILabel*lab3;
    //定义一个label,用来存储预期收益
    UILabel*lab4;
    
    //定义一个字典型数据，用来存储服务器返回数据
    NSDictionary*get_dic;
    
    //定义一个程序委托类
    AppDelegate*app;
    
    //定义一个故事版引用
    UIStoryboard*main;
    
    //定义一个定时器
    NSTimer*timer;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView;
}

@end

@implementation UserCentreView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 修饰拍照按钮属性
    [self.takePhoto setBackgroundImage:[UIImage imageNamed:@"post_avater_default.png"] forState:UIControlStateNormal];
     self.takePhoto.layer.cornerRadius=30;
    self.takePhoto.layer.masksToBounds=YES;
    //指定协议代理
    self.actionList.delegate=self;
    self.actionList.dataSource=self;
    
    //指定展示图片
    self.disImage.image=[UIImage imageNamed:@"default_cover.png"];
    
    //如果用户已通过实名认证，显示认证名
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"] isEqual:@""])
    {
         self.username.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
    }
   
    //实例化
    main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    //定义一个活动指示器
    activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, self.actionList.bounds.size.height/4, 80, 80);
    
    [self.actionList addSubview:activityView];
    [activityView startAnimating];
    //构造请求数据
    NSDictionary*send_dic=[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"];
    //向服务器请求数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/accountBalance.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        
        //数据请求成功
        if (operation.responseData)
        {
            get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];

            //积分
            self.score.text=[NSString stringWithFormat:@"积分:%@",[get_dic objectForKey:@"integral"]];
            
            //由于是tableView，所以其它值应该是通过表视图重载数据获得
            [self.actionList reloadData];
            
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //延时1秒再判断网络连接状态
    [self performSelector:@selector(judgeNet) withObject:nil afterDelay:1];
}

//待程序已经启动一段时间后判断网络连接状况
-(void)judgeNet
{
    if (app.Rea_manager.reachable==NO)
        
    {
        //网络未连接
        //提示用户，检查网络
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        //再次定义一个定时器，程序一旦进入后台，定时器就关闭了检测网络
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(requestAgain) userInfo:nil repeats:YES];
    }
}


//再次向服务器请求数据,成功即把定时器移除
-(void)requestAgain
{
    if (app.Rea_manager.reachable==YES)
    {
        //增加一个网络活动指示器
        [self.actionList addSubview:activityView];
        [activityView startAnimating];
        
        //构造请求数据
        NSDictionary*send_dic=[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"];
        //向服务器请求数据
        [app.manager POST:@"http://www.xiangnidai.com/dcs/app/accountBalance.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             
             //数据请求成功
             if (operation.responseData)
             {
                 get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                 
                 //积分
                 self.score.text=[NSString stringWithFormat:@"积分:%@",[get_dic objectForKey:@"integral"]];
                 //由于是tableView，所以其它值应该是通过表视图重载数据获得
                 [self.actionList reloadData];
                 
                 //定时器取消
                 [timer invalidate];
             }
         }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //活动指示器消失
             [activityView stopAnimating];
             [activityView removeFromSuperview];
             //提示用户，请求出错
             UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请求数据失败" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
             [alert addAction:action];
             [self presentViewController:alert animated:YES completion:nil];
         }];

    }
}



//上传头像
- (IBAction)takePhoto:(id)sender
{
    //弹出操作表单，供用户选择是从相库还是直接拍照
    UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"图片上传" message:@"请选择图片的来源" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction*action1=[UIAlertAction actionWithTitle:@"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        ///////
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            _imagePicker=[[UIImagePickerController alloc] init];
            _imagePicker.delegate=self;
            _imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
    }];
    
    UIAlertAction*action2=[UIAlertAction actionWithTitle:@"拍照上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        //拍照上传
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            _imagePicker=[[UIImagePickerController alloc] init];
            _imagePicker.delegate=self;
            _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
    }];
    
    UIAlertAction*action3=[UIAlertAction actionWithTitle:@"取消上传" style:UIAlertActionStyleCancel handler:nil];
                           
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    //弹出操作表
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma UITableViewDelegate/DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return 2;
    else if(section==1)
        return 2;
    else if(section==2)
        return 3;
    else
        return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置一个可重用标志
    static NSString*idnty=@"identifify";
    
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idnty];

    if (indexPath.section==0)
    {
        //配置单元格
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"今日收益";
            //自定义一个label,并配置其属性
            lab1=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-80, 0, 80, 44)];
            lab1.textColor=[UIColor redColor];
            lab1.textAlignment=NSTextAlignmentCenter;
            lab1.font=[UIFont boldSystemFontOfSize:15];
            
            //给lab1设置值,今日收益
            lab1.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"todayEarn"]];
            //将该label加入到cell的contentView中显示，而不是cell，否则label会上下移动
            [cell.contentView addSubview:lab1];
        }
        else
        {
            //自定义label--待收总金额
            UILabel*lab_num=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/3, 20)];
            lab_num.textAlignment=NSTextAlignmentCenter;
            lab_num.textColor=[UIColor blackColor];
            lab_num.font=[UIFont boldSystemFontOfSize:10];
            lab_num.text=@"待收总金额";
            [cell.contentView addSubview:lab_num];
            //自定义label
            lab2=[[UILabel alloc] initWithFrame:CGRectMake(0, 24, [UIScreen mainScreen].bounds.size.width/3, 20)];
            lab2.textColor=[UIColor blackColor];
            lab2.font=[UIFont boldSystemFontOfSize:10];
            lab2.textAlignment=NSTextAlignmentCenter;
            
            //指定lab2的值，待收入总金额
            lab2.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"stayEarn"]];
            [cell.contentView addSubview:lab2];
            
            //自定义label--本月收益
            UILabel*lab_get=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, 0, [UIScreen mainScreen].bounds.size.width/3, 20)];
            lab_get.textAlignment=NSTextAlignmentCenter;
            lab_get.textColor=[UIColor blackColor];
            lab_get.font=[UIFont boldSystemFontOfSize:10];
            lab_get.text=@"本月收益";
            [cell.contentView addSubview:lab_get];
            //自定义label
            lab3=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/3, 24, [UIScreen mainScreen].bounds.size.width/3, 20)];
            lab3.textColor=[UIColor blackColor];
            lab3.font=[UIFont boldSystemFontOfSize:10];
            lab3.textAlignment=NSTextAlignmentCenter;
            
            //指定lab2的值，本月收益
            lab3.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"tomonthEarn"]];
            [cell.contentView addSubview:lab3];
            
            
            //自定义label--待收总金额
            UILabel*lab_want=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*2/3, 0, [UIScreen mainScreen].bounds.size.width/3, 20)];
            lab_want.textAlignment=NSTextAlignmentCenter;
            lab_want.textColor=[UIColor blackColor];
            lab_want.font=[UIFont boldSystemFontOfSize:10];
            lab_want.text=@"预期收益";
            [cell.contentView addSubview:lab_want];
            //自定义label
            lab4=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*2/3, 24, [UIScreen mainScreen].bounds.size.width/3, 20)];
            lab4.textColor=[UIColor blackColor];
            lab4.font=[UIFont boldSystemFontOfSize:10];
            lab4.textAlignment=NSTextAlignmentCenter;
            //指定lab2的值，预期收益
            lab4.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"rightnowEarn"]];
            [cell.contentView addSubview:lab4];
        
        }
    }
    else if (indexPath.section==1)
    {
        if (indexPath.row==0)
        {
            //配置单元格
            cell.imageView.image=[UIImage imageNamed:@"1.png"];
            cell.textLabel.text=@"充值";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            //配置单元格
            cell.imageView.image=[UIImage imageNamed:@"6_2.png"];
            cell.textLabel.text=@"提现";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section==2)
    {
        if (indexPath.row==0)
        {
            //配置单元格
            cell.imageView.image=[UIImage imageNamed:@"7_2.png"];
            cell.textLabel.text=@"我的资料";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row==1)
        {
            //配置单元格
            cell.imageView.image=[UIImage imageNamed:@"2.png"];
            cell.textLabel.text=@"我的投资";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            //配置单元格
            cell.imageView.image=[UIImage imageNamed:@"8.png"];
            cell.textLabel.text=@"我的消息";
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if(indexPath.section==3)
    {
        //配置单元格
        cell.imageView.image=[UIImage imageNamed:@"5_2.png"];
        cell.textLabel.text=@"财务管理";
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section==4)
    {
        //配置单元格
        cell.imageView.image=[UIImage imageNamed:@"3.png"];
        cell.textLabel.text=@"奖励";
        //自定义添加label
        lab=[[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, 0, 60, 44)];
        lab.font=[UIFont boldSystemFontOfSize:12];
        lab.textColor=[UIColor blackColor];
        lab.textAlignment=NSTextAlignmentCenter;
        lab.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"award"]];
        [cell.contentView addSubview:lab];
    }
    else
    {
        //配置单元格
        cell.imageView.image=[UIImage imageNamed:@"11.png"];
        cell.textLabel.text=@"设置";
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

//点击单元格，跳转到下一个界面
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 1:
        {
            if (indexPath.row==0)
            {
                //充值功能尚在开发当中
                TopUpView*topupView=[main instantiateViewControllerWithIdentifier:@"topup"];
                topupView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                [self presentViewController:topupView animated:YES completion:nil];
            }
            else
            {
                if (app.Rea_manager.reachable==YES)
                {
                    //跳转到提现模块
                    GetCashView*cashView=[main instantiateViewControllerWithIdentifier:@"getcash"];
                    cashView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:cashView animated:YES completion:nil];
                }
                else
                {
                    UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }
        }
            break;
            
        case 2:
        {
            //先判断是否已经联网了
            if (app.Rea_manager.reachable==YES)
            {
                if (indexPath.row==0)
                {
                    
                    MyInfoView*infoView=[main instantiateViewControllerWithIdentifier:@"myinfo"];
                    infoView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:infoView animated:YES completion:nil];
                }
                else if (indexPath.row==1)
                {
                    //跳转到我的投资页面
                    MyInvestView*investView=[main instantiateViewControllerWithIdentifier:@"myinvest"];
                    investView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:investView animated:YES completion:nil];
                    
                }
                else
                {
                   //跳转到我的消息页面
                    MyNoticeView*notView=[main instantiateViewControllerWithIdentifier:@"mynotice"];
                    notView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:notView animated:YES completion:nil];
                }
            }
            else
            {
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
            break;
            //跳到财务管理界面
            case 3:
        {
            if (app.Rea_manager.reachable==YES)
            {
                main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PropertyManageView*managerView=[main instantiateViewControllerWithIdentifier:@"manager"];
                managerView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
                [self presentViewController:managerView animated:YES completion:nil];
            }
            else
            {
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
            break;
            //跳转到设置页面
            case 5:
        {
            main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SetUpView*setView=[main instantiateViewControllerWithIdentifier:@"setup"];
            setView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            [self presentViewController:setView animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
        
}

#pragma imagePicker

//取消
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取图像
    UIImage*originalImage=(UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    [self.takePhoto setBackgroundImage:originalImage forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
