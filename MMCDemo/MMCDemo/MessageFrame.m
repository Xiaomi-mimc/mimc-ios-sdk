//  MessageFrame.m
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.

#import "MessageFrame.h"
#import "NSString+Extension.h"

@implementation MessageFrame

- (void)setMessage:(Message *)message {
    _message = message;
    CGFloat padding = 10;
    
    if (NO == message.hideTime) {
        CGFloat timeWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat timeHeight = 40;
        CGFloat timeX = 0;
        CGFloat timeY = 0;
        _timeFrame = CGRectMake(timeX, timeY, timeWidth, timeHeight);
    }
    
    CGFloat iconWidth = 40;
    CGFloat iconHeight = 40;
    
    CGFloat iconX;
    if (MessageSent == message.type) {
        iconX = [UIScreen mainScreen].bounds.size.width - padding - iconWidth;
        _userNameFrame = CGRectMake(iconX - 60, CGRectGetMaxY(_timeFrame) + padding - 25, 100, iconHeight);
    } else {
        iconX = padding;
        _userNameFrame = CGRectMake(iconX, CGRectGetMaxY(_timeFrame) + padding - 25, 100, iconHeight);
    }
    
    CGFloat iconY = CGRectGetMaxY(_timeFrame) + padding;
    _iconFrame = CGRectMake(iconX, iconY, iconWidth, iconHeight);
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGSize textMaxSize = CGSizeMake(screenWidth - iconWidth - padding * 10, MAXFLOAT);
    CGSize textRealSize = [message.text sizeWithFont:MESSAGE_TEXT_FONT maxSize:textMaxSize];
    
    CGSize btnSize = CGSizeMake(textRealSize.width + TEXT_INSET*2, textRealSize.height + TEXT_INSET*2);
    
    CGFloat textX;
    if (MessageSent == message.type) {
        textX = CGRectGetMinX(_iconFrame) - btnSize.width - padding;
    } else {
        textX = CGRectGetMaxX(_iconFrame) + padding;
    }
    
    CGFloat textY = iconY;
    _textFrame = CGRectMake(textX, textY, btnSize.width, btnSize.height);
    
    CGFloat iconMaxY = CGRectGetMaxY(_iconFrame);
    CGFloat textMaxY = CGRectGetMaxY(_textFrame);
    _cellHeight = MAX(iconMaxY, textMaxY) + padding;
}
@end
