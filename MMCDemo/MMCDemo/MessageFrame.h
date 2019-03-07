//  MessageFrame.h
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.
// 存储每个cell内子控件的位置尺寸的frame

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Message.h"

#define MESSAGE_TIME_FONT [UIFont systemFontOfSize:13]
#define MESSAGE_TEXT_FONT [UIFont systemFontOfSize:15]
#define TEXT_INSET 20

@interface MessageFrame : NSObject

@property(nonatomic, assign, readonly) CGRect userNameFrame;
@property(nonatomic, assign, readonly) CGRect timeFrame;
@property(nonatomic, assign, readonly) CGRect iconFrame;
@property(nonatomic, assign, readonly) CGRect textFrame;

/** 信息model */
@property(nonatomic, strong) Message *message;
@property(nonatomic, assign) CGFloat cellHeight;
@end
