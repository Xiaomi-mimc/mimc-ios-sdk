//
//  voiceCallViewController.h
//  MMCDemo
//
//  Created by zhangdan on 2018/7/31.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBackBlcok) (int answer);

@interface voiceCallViewController : UIViewController
@property(nonatomic) NSString *receiver;
@property(nonatomic) NSString *audioConnState;
@property(nonatomic) int64_t callId;
@property(nonatomic) int numButton;
@property (nonatomic, copy)CallBackBlcok callBackBlock;
@end
