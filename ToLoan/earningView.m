//
//  earningView.m
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "earningView.h"
#import "AppDelegate.h"

@interface earningView ()
{
    AppDelegate*app;
    //定义一个字典，来存储服务器返回数据
    NSDictionary*get_dic;
}

@end

@implementation earningView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 指定tableView的代理及其外观属性
    self.earningList.dataSource=self;
    self.earningList.delegate=self;
    self.earningList.layer.cornerRadius=6.0f;
    self.earningList.layer.borderColor=[[UIColor grayColor] CGColor];
    self.earningList.layer.borderWidth=1.0f;
    self.earningList.scrollEnabled=NO;
    //实例化
    app=[UIApplication sharedApplication].delegate;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, 85, 80, 80)];
   
    activityView.color=[UIColor blackColor];
   
    [self.earningList addSubview:activityView];
    
    [activityView startAnimating];
    
    //向服务器请求数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getInvestInterest.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //活动指示器消失
         [activityView stopAnimating];
         [activityView removeFromSuperview];
         if (operation.responseData)
         {
             get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
             
             NSLog(@"get_dic=%@",get_dic);
             
            //表视图重载
             [self.earningList reloadData];
         }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //活动指示器消失
        [activityView stopAnimating];
        [activityView removeFromSuperview];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
    if (indexPath.row==0)
    {
        cell.textLabel.text=@"累计收益";
        cell.backgroundColor=[UIColor lightGrayColor];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"totalmoney"]];
    }
    else if (indexPath.row==1)
    {
        cell.textLabel.text=@"累计充值";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"topup"]];
    }
    else if (indexPath.row==2)
    {
        cell.textLabel.text=@"累计提现";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"getCash"]];
    }
    else if (indexPath.row==3)
    {
        cell.textLabel.text=@"累计投资";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"invest"]];
    }
    else
    {
        cell.textLabel.text=@"罚息收益";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@元",[get_dic objectForKey:@"fine"]];
    }
    return cell;
}

@end
