//
//  AboutUsView.m
//  ToLoan
//
//  Created by jway on 15-4-29.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "AboutUsView.h"

@interface AboutUsView ()
{
    //定义两个字符串，用来显示简介
    NSString*str1;
    NSString*str2;
}

@end

@implementation AboutUsView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 指定代理
    self.aboutus.dataSource=self;
    self.aboutus.delegate=self;
    //修饰外观
    self.aboutus.layer.cornerRadius=6.0f;
    self.aboutus.layer.borderColor=[[UIColor grayColor] CGColor];
    self.aboutus.layer.borderWidth=1.0f;
    //禁止滑动
    self.aboutus.scrollEnabled=NO;
    
    //简介内容
    str1=@"    武汉纵索科技发展有限公司的经营范围主要是涉及移动商务解决方案、移动增值服务运营和移动互联网服务与营销三大业务领域。积极倡导与促进企业和和技术厂商与服务商三者之间的合作，共同推进移动信息化在中国的发展。纵索科技是中国主要三大运营商资深的战略合作伙伴，在移动商务的平台，应用产品技术支持、销售渠道和服务网络等领域与其开展了全方位的深度合作，并积累了丰富的合作经验。武汉纵索科技发展有限公司面向企业在移动互联网趋势下的多重需求，基于3G技术架构先后开发了多款技术产品，推出了系列移动商务解决方案，凭借先进的研发理念，技术实力以及贴近客户需求的优势，推出企业微信营销平台--微智通、移动整合营销平台--掌。";
    str2=@"    想你贷P2P平台通过构建强大的信息收集、整理、分析、决策平台，合理实施互联网金融创新，整合各方资源，搭建起融商流、物流、信息流、资金流、工作流五六于一体的互联网金融服务平台。坚持第三方平台立场，充分披露各方信息，所有投资者详细的了解自己的每一笔资金流向，投资用途.";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//退出
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//先定义单元格的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
        return 35;
    else
        return [UIScreen mainScreen].bounds.size.height-284;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString*identy=@"Cell";
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
    
    if (indexPath.row==0)
    {
        cell.textLabel.text=@"公司简介";
        cell.backgroundColor=[UIColor lightGrayColor];
    }
    else
    {
        //定义两个label用来显示简介
        UILabel*lab1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 315/3*2-35)];
        
        lab1.font=[UIFont boldSystemFontOfSize:12];
        lab1.numberOfLines=13;
        lab1.textColor=[UIColor blackColor];
        lab1.textAlignment=NSTextAlignmentLeft;
        lab1.text=str1;
        [cell addSubview:lab1];
        
        UILabel*lab2=[[UILabel alloc] initWithFrame:CGRectMake(0, 315/3*2-35, 310, 315/3+35)];
        
        lab2.font=[UIFont boldSystemFontOfSize:12];
        lab2.numberOfLines=7;
        lab2.textColor=[UIColor blackColor];
        lab2.textAlignment=NSTextAlignmentLeft;
        lab2.text=str2;
        [cell addSubview:lab2];
 
    }
    return cell;
}

@end
