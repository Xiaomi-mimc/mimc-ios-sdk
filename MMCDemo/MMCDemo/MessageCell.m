//  MessageCell.m
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.

#import "MessageCell.h"
#import "MessageFrame.h"
#import "UIImage+Extension.h"

@interface MessageCell()

@property(nonatomic, weak) UILabel *userNameLabel;
@property(nonatomic, weak) UILabel *timeLabel;
@property(nonatomic, weak) UIImageView *iconView;
@property(nonatomic, weak) UIButton *textView;
@end

@implementation MessageCell



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (instancetype) cellWithTableView:(UITableView *) tableView {
    static NSString *ID = @"message";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (nil == cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = BACKGROUD_COLOR;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [timeLabel setFont:MESSAGE_TIME_FONT];
    [timeLabel setTextColor:[UIColor grayColor]];
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    UIImageView *iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconView];
    self.iconView = iconView;
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    [userNameLabel setFont:MESSAGE_TIME_FONT];
    [userNameLabel setTextColor:[UIColor purpleColor]];
    [self.contentView addSubview:userNameLabel];
    self.userNameLabel = userNameLabel;
    
    UIButton *textView = [[UIButton alloc] init];
    [textView setTitle:@"text" forState:UIControlStateNormal];
    [textView.titleLabel setFont:MESSAGE_TEXT_FONT];
    
    [textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [textView.titleLabel setNumberOfLines:0];
    
    textView.contentEdgeInsets = UIEdgeInsetsMake(TEXT_INSET, TEXT_INSET, TEXT_INSET, TEXT_INSET);
    
    [self.contentView addSubview:textView];
    self.textView = textView;
    
    return self;
}

- (void)setMessageFrame:(MessageFrame *) messageFrame {
    _messageFrame = messageFrame;
    
    self.userNameLabel.text = messageFrame.message.userName;
    if (MessageSent == messageFrame.message.type) {
        self.userNameLabel.textAlignment = NSTextAlignmentRight;
    } else {
        self.userNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    self.userNameLabel.frame = messageFrame.userNameFrame;
    
    self.timeLabel.text = messageFrame.message.time;
    self.timeLabel.frame = messageFrame.timeFrame;
    
    NSString *icon = (messageFrame.message.type == MessageSent)? @"me":@"you";
    self.iconView.image = [UIImage imageNamed:icon];
    self.iconView.frame = messageFrame.iconFrame;
    
    [self.textView setTitle:messageFrame.message.text forState:UIControlStateNormal];
    self.textView.frame = messageFrame.textFrame;
    
    NSString *chatImageNormalName;
    NSString *chatImageHighlightedName;
    if (MessageSent == messageFrame.message.type) {
        chatImageNormalName = @"chat_send_nor";
        chatImageHighlightedName = @"chat_send_press_pic";
    } else {
        chatImageNormalName = @"chat_recive_nor";
        chatImageHighlightedName = @"chat_recive_press_pic";
    }
    
    UIImage *chatImageNormal = [UIImage resizableImage:chatImageNormalName];
    UIImage *chatImageHighlighted = [UIImage resizableImage:chatImageHighlightedName];
    [self.textView setBackgroundImage:chatImageNormal forState:UIControlStateNormal];
    [self.textView setBackgroundImage:chatImageHighlighted forState:UIControlStateHighlighted];
}
@end

