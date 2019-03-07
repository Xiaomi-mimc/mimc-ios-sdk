//
//  NSString+Extension.h
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.
// NSString扩展类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Extension)

- (CGSize) sizeWithFont:(UIFont *)font maxSize:(CGSize) maxSize;
@end
