//
//  UserCentreView.h
//  ToLoan
//
//  Created by jway on 15-4-20.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCentreView : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
//顶部显示图片

@property (weak, nonatomic) IBOutlet UIImageView *disImage;

//拍照按钮
- (IBAction)takePhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *takePhoto;

//积分数
@property (weak, nonatomic) IBOutlet UILabel *score;

//操作表单
@property (weak, nonatomic) IBOutlet UITableView *actionList;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *username;

@property(nonatomic,strong)UIImagePickerController*imagePicker;

@end
