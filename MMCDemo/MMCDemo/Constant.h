//
//  Constant.h
//  MMCDemo
//
//  Created by lijia8 on 2018/12/29.
//  Copyright © 2018 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 检查用户在线
 * 用户A通过MIMC发送ping给用户B
 * 用户B接收到ping后，通过MIMC发送pong给用户A
 */
extern NSString* const PING;
extern NSString* const PONG;
//文本消息
extern NSString* const TEXT;
/**
 * 用户A将图片文件/语音文件/视频文件(非实时语音视频聊天)上传到文件存储服务器，获得一个URL
 * 用户A通过MIMC发送多媒体消息(content=URL)给用户B
 * 用户B接收多媒体消息(content=URL)，通过URL下载图片文件/语音文件/视频文件
 */
extern NSString* const PIC_FILE;
//已读消息，content为已读消息msgId
extern NSString* const TEXT_READ;
//撤回消息，content为撤回消息msgId
extern NSString* const TEXT_RECALL;
extern NSString* const ADD_FRIEND_REQUEST;
//content为true or false,表示同意或拒绝
extern NSString* const ADD_FRIEND_RESPONSE;

@interface Constant : NSObject {
    
}

@end
