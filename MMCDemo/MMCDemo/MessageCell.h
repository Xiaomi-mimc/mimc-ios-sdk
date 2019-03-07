//  MessageCell.h
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.

#import <UIKit/UIKit.h>

#define BACKGROUD_COLOR [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0]

@class MessageFrame, Message;

@interface MessageCell : UITableViewCell

@property(nonatomic, strong) MessageFrame *messageFrame;

+ (instancetype) cellWithTableView:(UITableView *) tableView;
@end
