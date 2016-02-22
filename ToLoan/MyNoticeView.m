//
//  MyNoticeView.m
//  ToLoan
//
//  Created by jway on 15-5-2.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "MyNoticeView.h"
#import "AppDelegate.h"

#import "CustomCell3.h"

@interface MyNoticeView ()
{
    //定义一个程序委托类
    AppDelegate*app;
    
    //定义一个可变数组，用来接受服务器返回的数据
    NSArray*notArray;
}

@end

@implementation MyNoticeView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 指定代理
    self.noticeList.dataSource=self;
    self.noticeList.delegate=self;
    
    //实例化程序委托
    app=[UIApplication sharedApplication].delegate;
    
    //向服务器请求消息数据
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getMessages.do" parameters:[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"] success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        notArray=[[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil]];
        
        //表视图重载数据
        [self.noticeList reloadData];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //
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

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^
    {
        notArray=nil;
    }];
}

#pragma tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return notArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 12;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell3*cell=[tableView dequeueReusableCellWithIdentifier:@"cell3"];
    
    cell.title.text=[[notArray objectAtIndex:indexPath.section] objectForKey:@"title"];
    
    cell.message.text=[[notArray objectAtIndex:indexPath.section] objectForKey:@"detail"];
    
    //设置日期格式
    NSDateFormatter*formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate*date=[NSDate dateWithTimeIntervalSince1970:[[[notArray objectAtIndex:indexPath.section] objectForKey:@"time"] integerValue]];
    
    cell.time.text=[formatter stringFromDate:date];
    
    return cell;
}
@end
