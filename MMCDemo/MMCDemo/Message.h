//  Message.h
//  MMCDemo
//
//  Created by zhangdan on 2018/1/10.
//  Copyright © 2018年 zhangdan. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum {
    MessageSent = 0, // 我发出的信息
    MessageRecved = 1 // 对方发出的信息
} MessageType;

@interface Message : NSObject

@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, assign) MessageType type;

@property(nonatomic, assign) BOOL hideTime;

- (instancetype) initWithDictionary:(NSDictionary *) dictionary;
+ (instancetype) messageWithDictionary:(NSDictionary *) dictionary;
+ (instancetype) message;

@end
