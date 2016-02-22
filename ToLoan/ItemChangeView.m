//
//  ItemChangeView.m
//  ToLoan
//
//  Created by jway on 15-4-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "ItemChangeView.h"
#import "AppDelegate.h"
#import "CustomCell2.h"
@interface ItemChangeView ()
{
    //定义一个程序委托代理
    AppDelegate*app;
    //定义一个表示图，用来存储“转让记录”
    UITableView*itemList_temp;
    
    //定义一个flag用来标识上次按的是哪个分段部分
    int flag;
}

@end

@implementation ItemChangeView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 指定代理
    self.itemList.dataSource=self;
    self.itemList.delegate=self;
    //定义一个表视图，加入到滑动视图上
    itemList_temp=[[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 118, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-167) style:UITableViewStylePlain];
    //给其分配一个tag
    itemList_temp.tag=2;
    itemList_temp.delegate=self;
    itemList_temp.dataSource=self;
    //加载到主视图
    [self.view addSubview:itemList_temp];
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    
    //指定当前flag的值
    
    if (self.changeItem.selectedSegmentIndex==0)
        flag=0;
    else if (self.changeItem.selectedSegmentIndex==1)
        flag=1;
    else
        flag=2;
   
    //向服务器请求数据
    //构造发送数据
    NSDictionary*send_dic=[NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] forKey:@"username"];
    [app.manager POST:@"http://www.xiangnidai.com/dcs/app/TODO" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (operation.responseData)
        {
            NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options: NSJSONReadingMutableContainers error:nil];
            NSLog(@"get_dic=%@",get_dic);
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        ///不要报错
    }];
    
    
    //self.array_list1=[[NSMutableArray alloc] initWithObjects:dic1,dic2,nil];
    ////////////////////////////
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//分段控件，执行分屏操作

- (IBAction)chcangeItem:(id)sender
{
    //判断是否要重新加载表视图及更新数据
    if(self.changeItem.selectedSegmentIndex==0&&flag!=0)
    {
        /*
        //向服务器请求数据--用于更新
        [app.manager POST:nil parameters:nil success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                nil;
        }];
        */
        ////////////////////////
        //伪造数据
  //      NSDictionary*dic1=[NSDictionary dictionaryWithObjectsAndKeys:@"天力贷201502",@"name",@"221,767元",@"itemNum",@"24,659元",@"enableNum",@"收益中",@"state",nil];
            
 //       NSDictionary*dic2=[NSDictionary dictionaryWithObjectsAndKeys:@"天力贷201502",@"name",@"231,767元",@"itemNum",@"214,659元",@"enableNum",@"招标中",@"state",nil];
   //         self.array_list1=[[NSMutableArray alloc] initWithObjects:dic1,dic2,nil];
        ////////////////////////////////
        //判断是否要将转让记录表示图移出显示窗口，并同时显示债权记录
        if (flag==2)
        {
            [UIView animateWithDuration:0.4 animations:^{
                itemList_temp.frame=CGRectMake([UIScreen mainScreen].bounds.size.width, 118, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-167);
                //显示债权表示图
                self.itemList.hidden=NO;
                
            } completion:^(BOOL finished)
            {
               
                //重新加载表示图
                [self.itemList reloadData];
                //更新flag的值
                flag=0;
            }];
        }
        else
        {
            [self.itemList reloadData];
            flag=0;
        }
       
            
        

    }
    else if (self.changeItem.selectedSegmentIndex==1&&flag!=1)
    {
        /*
        //向服务器请求数据/或更新数据
        [app.manager POST:nil parameters:nil success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                nil;
        }];
        */
        //伪造数据
        ////////////////////////
   //     NSDictionary*dic1=[NSDictionary dictionaryWithObjectsAndKeys:@"天力贷201502",@"name",@"221,767元",@"itemNum",@"24,659元",@"enableNum",@"收益中",@"state",nil];
            
  //      NSDictionary*dic2=[NSDictionary dictionaryWithObjectsAndKeys:@"RFID201502",@"name",@"21,767元",@"itemNum",@"514,659元",@"enableNum",@"收益中",@"state",nil];
  //      self.array_list2=[[NSMutableArray alloc] initWithObjects:dic1,dic2,nil];
        ////////////////////////////
        //如果点击的是“转让中”，则视图不动，只需要更新数据
        if (flag==0)
        {
            [self.itemList reloadData];
            flag=1;
        }
        //如果当前显示的是“转让记录”，那么除了需要更新表示图，还要切换显示从转让记录表（即itemList_temp）到债权表（itemList）
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                itemList_temp.frame=CGRectMake([UIScreen mainScreen].bounds.size.width,118, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-167);
                self.itemList.hidden=NO;
                
            } completion:^(BOOL finished)
             {
                 [self.itemList reloadData];
                 flag=1;
            }];
        }
        
    }
    else if(self.changeItem.selectedSegmentIndex==2&&flag!=2)
    {
        /*
        //向服务器请求数据/更新数据，并移动到“转让记录”页面
        [app.manager POST:nil parameters:nil success:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                nil;
        }];
        */
        //伪造数据
        ////////////////////////
   //     NSDictionary*dic1=[NSDictionary dictionaryWithObjectsAndKeys:@"天力贷201502",@"name",@"2015-02-24 14:34",@"time",nil];
  //      NSDictionary*dic2=[NSDictionary dictionaryWithObjectsAndKeys:@"RFID201502",@"name",@"2015-02-24 14:34",@"time",nil];
  //      self.array_list3=[[NSMutableArray alloc] initWithObjects:dic1,dic2,nil];
            
        ////////////////////////////
        //加载显示转让记录表视图
        [UIView animateWithDuration:0.3 animations:^{
            self.itemList.hidden=YES;
            itemList_temp.frame=CGRectMake(0, 118, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-167);
        } completion:^(BOOL finished)
         {
             //重新加载表视图
             [itemList_temp reloadData];
             flag=2;
        }];
    }
}

#pragma Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.changeItem.selectedSegmentIndex==0)
        return self.array_list1.count;
    else if (self.changeItem.selectedSegmentIndex==1)
        return self.array_list2.count;
    else
        return self.array_list3.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==2)
    {
        ////////
        static NSString*Cell=@"identity";
        UITableViewCell*cell1=[tableView dequeueReusableCellWithIdentifier:Cell];
        if (cell1==nil)
        {
            cell1=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Cell];
        }
        cell1.imageView.image=[UIImage imageNamed:@"icon_pinlun.png"];
        cell1.textLabel.text=[[self.array_list3 objectAtIndex:indexPath.section] objectForKey:@"name"];
        cell1.detailTextLabel.text=[[self.array_list3 objectAtIndex:indexPath.section] objectForKey:@"time"];
        return cell1;
    }
    else
    {
        NSString*ident=@"Cell_temp";
        CustomCell2*cell2=[tableView dequeueReusableCellWithIdentifier:ident];
        //配置cell
       if (self.changeItem.selectedSegmentIndex==0)
        {
            cell2.name.text=[[self.array_list1 objectAtIndex:indexPath.section] objectForKey:@"name"];
            cell2.itemNum.text=[[self.array_list1 objectAtIndex:indexPath.section] objectForKey:@"itemNum"];
            cell2.enableNum.text=[[self.array_list1 objectAtIndex:indexPath.section] objectForKey:@"enableNum"];
            cell2.state.text=[[self.array_list1 objectAtIndex:indexPath.section] objectForKey:@"state"];
           
        }
       else
        {
            cell2.name.text=[[self.array_list2 objectAtIndex:indexPath.section] objectForKey:@"name"];
            cell2.itemNum.text=[[self.array_list2 objectAtIndex:indexPath.section] objectForKey:@"itemNum"];
            cell2.enableNum.text=[[self.array_list2 objectAtIndex:indexPath.section] objectForKey:@"enableNum"];
            cell2.state.text=[[self.array_list2 objectAtIndex:indexPath.section] objectForKey:@"state"];
           
        }
        return cell2;
    }
     
}

//表足的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return (tableView.tag==1)?15:0;
}
@end
