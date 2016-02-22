//
//  TabBarView.m
//  ToLoan
//
//  Created by jway on 15-4-19.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import "TabBarView.h"
#import "AppDelegate.h"
#import "SignInView.h"
@interface TabBarView ()
{
    //定义一个程序委托类
    AppDelegate*app;
}

@end

@implementation TabBarView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate=self;
    self.tabBar.tintColor=[UIColor redColor];
    
    //实例化程序委托类
    app=[UIApplication sharedApplication].delegate;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma UITabBarController
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   
    
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    //当点击“债权转让”页面时如果用户未登录，要跳转到登录界面
    
        if ([viewController.title isEqual:@"债权转让"]||[viewController.title isEqual:@"财富中心"])
        {
            //用户未登录
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userstate"] intValue]==0)
            {
               //跳转到登录页面
               UIStoryboard*main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
               SignInView*signinView=[main instantiateViewControllerWithIdentifier:@"signin"];
               signinView.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
               [self presentViewController:signinView animated:YES completion:nil];
               return NO;
            }
            else
                return YES;
        }
        else
            return YES;
 
}

@end
