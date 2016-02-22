//
//  SetUpView.m
//  ToLoan
//
//  Created by jway on 15-4-23.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "SetUpView.h"
#import "TabBarView.h"
#import "AboutUsView.h"
@interface SetUpView ()
{
    //定义一个故事版引用
    UIStoryboard*main;
}

@end

@implementation SetUpView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //指定代理，并设置属性
    self.setUp_list.dataSource=self;
    self.setUp_list.delegate=self;
    self.setUp_list.backgroundColor=[UIColor clearColor];
    self.setUp_list.scrollEnabled=NO;
    //实例化
    main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
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

#pragma UITableViewDelegate/DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identy];
    if (indexPath.section==0)
    {
        cell.textLabel.text=@"检测更新";
        
        //当前版本，这个值应该来自于服务器，此处只做测试
        cell.detailTextLabel.text=@"当前版本V1.0";
        cell.detailTextLabel.font=[UIFont boldSystemFontOfSize:10];
    }
    else if(indexPath.section==1)
    {
        cell.textLabel.text=@"关于我们";
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.textLabel.text=@"退出";
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==1)
    {
        //跳到关于我们界面
        AboutUsView*aboutView=[main instantiateViewControllerWithIdentifier:@"aboutus"];
        aboutView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:aboutView animated:YES completion:nil];
        
    }
    else if (indexPath.section==2)
    {
        if (indexPath.row==0)
        {
            //退出操作在本地执行
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"userstate"];
            //返回到首页
            TabBarView*tabVView=[main instantiateViewControllerWithIdentifier:@"mainbar"];
            tabVView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
            [self presentViewController:tabVView animated:YES completion:nil];
        }
       
    }
}
@end
