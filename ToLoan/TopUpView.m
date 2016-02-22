//
//  TopUpView.m
//  ToLoan
//
//  Created by jway on 15-5-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "TopUpView.h"
#import "BaoFooPayController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
@interface TopUpView ()
{
    //hub指示器
    MBProgressHUD*hud;
    //定义一个程序委托类
    AppDelegate*app;
    
    //定义一个字符串，存放服务器返回交易流水号引用
    NSString*transId_temp;
    
    //用于宝付接口返回数据
    NSMutableData*receiveData;
}

@end

@implementation TopUpView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //修饰按钮外观
    self.payMoney.layer.cornerRadius=4.0f;
    //设置输入框边框初始颜色
    self.money.layer.borderColor=[[UIColor grayColor] CGColor];
    //定义一个活动指示器，用于关闭键盘
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//关闭键盘
-(void)handTap
{
    [self.money resignFirstResponder];
}

//确认付款
- (IBAction)payMoney:(id)sender
{
    if ([self.money.text isEqual:@""])
    {
        UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"充值金额不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        //如果网络未连接，提示用户
        if (app.Rea_manager.reachable==NO)
        {
            UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络连接已断开，请前往设置" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            //按钮可交互性设置为NO
            self.payMoney.userInteractionEnabled=NO;
            self.payMoney.backgroundColor=[UIColor grayColor];
            
            //调用宝付接口
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.color = [UIColor colorWithRed:51.0f/250.0f green:51.0f/250.0f blue:51.0f/250.0f alpha:1.0];//
            [hud hide:YES afterDelay:60.0];
            //hud.cornerRadius = 50;
            hud.yOffset = 10;
            
            
            //构造发送数据
            NSDictionary*send_dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"userName",self.money.text,@"orderMoney",nil];
            
            //向服务器请求交易流水号
            [app.manager POST:@"http://www.xiangnidai.com/dcs/app/getOrderNo.do" parameters:send_dic success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                
                //成功返回信息
                NSDictionary*get_dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"get_dic=%@",get_dic);
                
                //判断是否请求流水号成功
                if ([[get_dic objectForKey:@"state"] intValue]==1)
                {
                    //存下流水号
                    transId_temp=[get_dic objectForKey:@"tradeNo"];
                    
                    //测试商户号
                    NSString* memberId = @"100000178";
                    
                    //测试终端号
                    NSString* terminalId = @"10000001";
                    
                    //测试秘钥
                    NSString* key= @"abcdefg";
                    
                    //宝付测试支付地址
                    NSString*urlSSSSSSSSSSSS = @"http://tgw.baofoo.com/paysdk/index";
                    [self request:urlSSSSSSSSSSSS With:memberId With:terminalId With:key];
                }
                else
                {
                    //请求流水号失败
                    UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[get_dic objectForKey:@"errmsg"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:action];
                    [self presentViewController:alert animated:YES completion:nil];                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                //访问服务器失败
                UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"访问服务器失败" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];            }];
            
        }
        
    }
}

-(void)request:(NSString*)urlssss With:(NSString*)ssmemberId With:(NSString*)ssterminalId With:(NSString*)sskey
{
    
    //服务器通知地址
    NSString*returnUrl = @"http://tgw.baofoo.com/testPage/server/4.0/ok/1";
    
    //页面通知地址，sdk版本默认为空
    NSString*pageUrl = @"";
    
    //支付ID，sdk版本默认为空
    //   NSString*payId = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    //交易时间
    NSString *tradeDate = [dateFormatter stringFromDate:[NSDate date]];
    
    //用户流水号
    NSString*transId = transId_temp;
    
    
    //   NSString*noticeType = @"0";
    
    //加密类型，sdk版本默认为1
    //    NSString*keyType = @"1";
    
    //接口版本号，sdk默认为4.0
    //   NSString*interfaceVersion = @"4.0";
    
    //通知方式 默认sdk版本为0
    //   NSString*NoticeType = @"0";
    
    //订单金额
    NSNumber *number = [NSNumber numberWithFloat:([_money.text floatValue])*100];
    NSString*realMoney= [number stringValue];
    
    //商品名称，需要url编码
    NSString*commodityName = [@"宝付测试商品"stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //用户名称
    NSString*userName = [[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //额外信息
    NSString*AdditionalInfo = [@"helloworld" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    returnUrl = [returnUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //
    NSString*temp = [NSString stringWithFormat:@"%@||%@|%@|%@||%@|0|%@",ssmemberId,tradeDate,transId,realMoney,returnUrl,sskey];
    
    //签名，将交易关键数据进行拼接
    NSString *signature = [self md5:temp];
    
    //构造发送数据
    NSString*post = [[NSString alloc] initWithFormat:@"MemberID=%@&TerminalID=%@&PayID=&TradeDate=%@&TransID=%@&OrderMoney=%@&InterfaceVersion=4.0&CommodityName=%@&CommodityAmount=1&UserName=%@&AdditionalInfo=%@&PageUrl=%@&ReturnUrl=%@&KeyType=1&NoticeType=0&Signature=%@",ssmemberId,ssterminalId,tradeDate,transId,realMoney,commodityName,userName,AdditionalInfo,pageUrl,returnUrl,signature];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    //向服务器发送请求
    NSURL* url = [NSURL URLWithString:urlssss];
    NSMutableURLRequest * urlRequest=[NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [urlConn start];
}

//这是协议方法
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    //这是初始化对象
    receiveData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receiveData appendData:data];
    [hud hide:YES];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:receiveData options:kNilOptions error:nil];
    if (([[dict objectForKey:@"retCode"] isEqualToString:@"0000"])&&([dict objectForKey:@"tradeNo"]))
    {
        //呈现宝府支付web页面
        BaoFooPayController*web = [[BaoFooPayController alloc] init];
        web.PAY_TOKEN = [dict objectForKey:@"tradeNo"];
        web.delegate = self;
        //这是测试版本
        web.PAY_BUSINESS = @"fals";
        [self presentViewController:web animated:YES completion:^{
            
            //恢复按钮的可交互性
            self.payMoney.userInteractionEnabled=YES;
            self.payMoney.backgroundColor=[UIColor redColor];
        }];
    }
    else
    {
        NSString*str = [dict objectForKey:@"retMsg"];
        if (!str) {
            str = @"创建订单号失败";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [hud hide:YES];
        [alert show];
    }
}

//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络连接有问题哦，请检查网路后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [hud hide:YES];
    [alert show];
    NSLog(@"%@",[error localizedDescription]);
}


//返回操作
- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        transId_temp=nil;
    }];
}

//md5算法加密
- (NSString *)md5:(NSString *)str {
    
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

#pragma UItextFiledDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.money.layer.borderColor=[[UIColor orangeColor] CGColor];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.money.layer.borderColor=[[UIColor grayColor] CGColor];
}
//关闭键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.money resignFirstResponder];
    return YES;
}

#pragma mark - BaofooDelegate
-(void)callBack:(NSString*)params
{
   
    UIAlertController*alert=[UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"支付结果:%@",params] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction*action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        //恢复按钮的可交互性
        self.payMoney.userInteractionEnabled=YES;
        self.payMoney.backgroundColor=[UIColor redColor];
    }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
