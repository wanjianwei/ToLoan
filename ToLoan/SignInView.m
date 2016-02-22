//
//  SignInView.m
//  ToLoan
//
//  Created by jway on 15-4-22.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "SignInView.h"
#import "AppDelegate.h"
#import "RegisterView.h"
#import "TabBarView.h"
#import "ForgetPWView.h"
#import <CommonCrypto/CommonDigest.h>
@interface SignInView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    //定义一个用户名输入框
    UITextField*username;
    //定义一个密码输入框
    UITextField*password;
    //定义一个故事版引用
    UIStoryboard*main;
}

@end

@implementation SignInView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理
    self.infoPart.dataSource=self;
    self.infoPart.delegate=self;
    self.infoPart.backgroundColor=[UIColor clearColor];
    self.infoPart.scrollEnabled=NO;
    //修饰按钮外观
    self.signIn.layer.cornerRadius=4.0f;
    //修饰头像
    self.portrait.layer.cornerRadius=50;
    self.portrait.layer.masksToBounds=YES;
    
    //注册手势处理器，用来关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
    //程序委托类初始化
    app=[UIApplication sharedApplication].delegate;
    
    //初始化故事版引用
    main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//关闭键盘
-(void)handTap
{
    [username resignFirstResponder];
    [password resignFirstResponder];
}

//跳转到注册界面
- (IBAction)register_now:(id)sender
{
    //跳转到注册界面
    main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterView*registerView=[main instantiateViewControllerWithIdentifier:@"register"];
    registerView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:registerView animated:YES completion:nil];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//登录操作
- (IBAction)signIn:(id)sender
{
    
    if (app.Rea_manager.reachable==YES)
    {
        if ([username.text isEqual:@""]||[password.text isEqual:@""])
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请将登录信息填写完整" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            //定义一个活动指示器
            UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] init];
            activityView.color=[UIColor blackColor];
            activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
            [self.view addSubview:activityView];
            [activityView startAnimating];
            
            //一旦发送数据，登录按钮的可交互性就应当设置为NO
            self.signIn.userInteractionEnabled=NO;
            
            //构造发送给服务器的数据
            NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:username.text,@"username",[self md5HexDigest:[password text]],@"password",nil];
            
            //向服务器发送登录信息
            [app.manager POST:@"http://www.xiangnidai.com/dcs/app/login.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 if (operation.responseData)
                 {
                     NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                     
                     
                     if ([[get_dic objectForKey:@"state"] intValue]==1)
                     {
                         //登录成功,登录视图消失,此时需要把头像地址持久存储
                         //头像地址存起来
                         
                         [[NSUserDefaults standardUserDefaults] setObject:[[get_dic objectForKey:@"user"] objectForKey:@"avatar"] forKey:@"avatar"];
                         
                         //开启另一个线程，把头像下载到本地
                         //         NSThread*thread=[[NSThread alloc] initWithTarget:self selector:@selector(getPortrait) object:nil];
                         
                         //          [thread start];
                         
                         //用户状态设置为登录成功
                         
                         [[NSUserDefaults standardUserDefaults] setObject:[get_dic objectForKey:@"state"] forKey:@"userstate"];
                         
                         //用户名也要存起来，方便登录后的查询操作
                         [[NSUserDefaults standardUserDefaults] setObject:[[get_dic objectForKey:@"user"] objectForKey:@"username"] forKey:@"username"];
                         
                         //用户认证成功后的名字也会返回，一并存储
                         [[NSUserDefaults standardUserDefaults] setObject:[[get_dic objectForKey:@"user"] objectForKey:@"nickname"] forKey:@"nickname"];
                         
                         //活动指示器消失
                         [activityView stopAnimating];
                         [activityView removeFromSuperview];
                         
                         //登录成功
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                     else
                     {
                         //移除活动指示器
                         [activityView stopAnimating];
                         [activityView removeFromSuperview];
                         //登录失败，返回提示
                         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或密码错误" preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                         {
                             //恢复按钮的交互性
                             self.signIn.userInteractionEnabled=YES;
                             
                         }];
                         [alert addAction:action];
                         [self presentViewController:alert animated:YES completion:nil];
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             
             {
                 //活动指示器消失
                 [activityView stopAnimating];
                 [activityView removeFromSuperview];
                 //登录失败，返回提示
                 UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"请求服务器失败" preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction*action=[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                       {
                                           //恢复按钮的交互性
                                           self.signIn.userInteractionEnabled=YES;
                                           
                                       }];
                 [alert addAction:action];
                 [self presentViewController:alert animated:YES completion:nil];
                 
             }];
        }

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

//下载头像到本地--可以开一个线程用NSDate

//忘记密码
- (IBAction)forget_pw:(id)sender
{
    //跳转到忘记密码界面
    ForgetPWView*pwView=[main instantiateViewControllerWithIdentifier:@"forgetpw"];
    pwView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:pwView animated:YES completion:nil];
}

#pragma UITableViewDelegate/dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*identy=@"Cell";
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:identy];
    if (cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
    }
    if (indexPath.section==0)
    {
        cell.imageView.image=[UIImage imageNamed:@"login_icon_account.png"];
    
        //定义一个UITextField
        username=[[UITextField alloc] initWithFrame:CGRectMake(60, 2, 200, 40)];
        username.placeholder=@"请输入您的账号";
        username.delegate=self;
        [cell addSubview:username];
        cell.layer.cornerRadius=2.5f;
        return cell;
    }
    else
    {
        cell.imageView.image=[UIImage imageNamed:@"login_icon_password.png"];
        //定义一个UITextField
        password=[[UITextField alloc] initWithFrame:CGRectMake(60, 2, 200, 40)];
        password.placeholder=@"请输入您的密码";
        //密码用暗文输入
        password.secureTextEntry=YES;
        password.delegate=self;
        [cell addSubview:password];
        cell.layer.cornerRadius=2.5f;
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 22;
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

//获取存储头像的本地地址
-(NSString*)filePath
{
    //找到Documents文件所在的路径
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //取得第一个Documents文件夹的路径
    NSString *filePath = [path objectAtIndex:0];
    //获取完整保存路径-每张头像用用户名来区分地址
    NSString *plistPath= [filePath stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    return plistPath;
}


@end
