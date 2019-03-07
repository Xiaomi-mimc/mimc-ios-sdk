//  UIImage+Extension.m
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.
// NSImage 类的扩展

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

+ (UIImage *) resizableImage:(NSString *) imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIEdgeInsets insets = UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2 + 1, image.size.width/2 + 1);
    return [image resizableImageWithCapInsets:insets];
}

@end
