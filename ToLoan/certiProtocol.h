//
//  certiProtocol.h
//  ToLoan
//
//  Created by jway on 15-4-28.
//  Copyright (c) 2015年 jway. All rights reserved.
//

#ifndef ToLoan_certiProtocol_h
#define ToLoan_certiProtocol_h
@protocol certiProtocol
@optional
//已经完成实名认证
-(void)hasNameCerti:(NSString*)certiID;

//已经完成手机认证
-(void)hasPhoneCerti:(NSString*)phoneNum;

//已经完成银行卡认证
-(void)hasBankNumCerti:(NSDictionary*)dic;

//已经完成支付密码设置
-(void)hasSetPW;

//已经完成银行选择
-(void)hasFinishChose:(UIImage*)image With:(NSDictionary*)text;
@end

#endif
