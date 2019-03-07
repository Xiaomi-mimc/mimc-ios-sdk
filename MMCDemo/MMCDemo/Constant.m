//
//  Constant.m
//  MMCDemo
//
//  Created by lijia8 on 2018/12/29.
//  Copyright © 2018 mimc. All rights reserved.
//

#import "Constant.h"

/**
 * 检查用户在线
 * 用户A通过MIMC发送ping给用户B
 * 用户B接收到ping后，通过MIMC发送pong给用户A
 */
NSString* const PING = @"PING";
NSString* const PONG = @"PONG";
//文本消息
NSString* const TEXT = @"TEXT";
/**
 * 用户A将图片文件/语音文件/视频文件(非实时语音视频聊天)上传到文件存储服务器，获得一个URL
 * 用户A通过MIMC发送多媒体消息(content=URL)给用户B
 * 用户B接收多媒体消息(content=URL)，通过URL下载图片文件/语音文件/视频文件
 */
NSString* const PIC_FILE = @"PIC_FILE";
//已读消息，content为已读消息msgId
NSString* const TEXT_READ = @"TEXT_READ";
//撤回消息，content为撤回消息msgId
NSString* const TEXT_RECALL = @"TEXT_RECALL";
NSString* const ADD_FRIEND_REQUEST = @"ADD_FRIEND_REQUEST";
//content为true or false,表示同意或拒绝
NSString* const ADD_FRIEND_RESPONSE = @"ADD_FRIEND_RESPONSE";

@implementation Constant

@end
