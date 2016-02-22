//
//  ChoseBankView.m
//  ToLoan
//
//  Created by jway on 15-4-30.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "ChoseBankView.h"
#import "AppDelegate.h"
#import "CustomCell4.h"
@interface ChoseBankView ()
{
    //定义一个程序委托
    AppDelegate*app;
    
    //定义一个数组，用来存储服务器返回的数据
    NSArray*array_get;
    
    //定义一个可变数组，用来存放银行logo
    NSMutableArray*imageArray;
}

@end

@implementation ChoseBankView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //指定代理
    self.bankList.dataSource=self;
    self.bankList.delegate=self;
    
    //实例化可变数组
    imageArray=[[NSMutableArray alloc] init];
    
    //实例化程序委托
    app=[UIApplication sharedApplication].delegate;
    
    //定义一个活动指示器
    UIActivityIndicatorView*activityView=[[UIActivityIndicatorView alloc] init];
    activityView.color=[UIColor blackColor];
    activityView.frame=CGRectMake([UIScreen mainScreen].bounds.size.width/2-40, [UIScreen mainScreen].bounds.size.height/2-40, 80, 80);
    [self.bankList addSubview:activityView];
    [activityView startAnimating];
    
    //向服务器请求数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getBanks.do" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //如果返回成功
         array_get=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
         //成功了活动指示器消失
         [activityView stopAnimating];
         [activityView removeFromSuperview];
         //重新载入数据
         [self.bankList reloadData];
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         //成功了活动指示器消失
         [activityView stopAnimating];
         [activityView removeFromSuperview];
         //提示用户，请求出错
         UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"服务器或网络出现异常" preferredStyle:UIAlertControllerStyleAlert];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    // Return the number of rows in the section.
    return  array_get.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell4 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell4" forIndexPath:indexPath];
    
    // Configure the cell...
    
    //如果该银行有图标
    if (![[[array_get objectAtIndex:indexPath.row] objectForKey:@"icon"] isEqual:@""])
    {
        
        //构造图片地址
        NSString*urlpath=[NSString stringWithFormat:@"http://www.xiangnidai.com/dcs/%@",[[array_get objectAtIndex:indexPath.row] objectForKey:@"icon"]];
        
        //从网络中获取图片数据
        NSData*data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlpath]];
        
        //加载图片，如果返回图片二进制为空，则加载默认图片
        if (data!=nil)
            //设置图片
            cell.image.image=[[UIImage alloc] initWithData:data];
        else
            cell.image.image=[UIImage imageNamed:@"post_avater_default.png"];
        
    }
    else
    {
        cell.image.image=[UIImage imageNamed:@"post_avater_default.png"];
    }
    //将图片转入可变数组中
    [imageArray addObject:cell.image.image];
    
    cell.imageName.text=[[array_get objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //将银行图片和名称传到上个模块
    [self.delegate hasFinishChose:[imageArray objectAtIndex:indexPath.row] With:[array_get objectAtIndex:indexPath.row]];
    
    //关闭视图，此时释放对象，节约内存
    [self dismissViewControllerAnimated:YES completion:^
    {
        array_get=nil;
        imageArray=nil;
    }];
    
    
}


@end
