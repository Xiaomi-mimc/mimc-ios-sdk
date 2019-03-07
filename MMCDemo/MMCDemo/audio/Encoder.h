//
//  Encoder.h
//  MMCDemo
//
//  Created by lijia8 on 2018/12/14.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encoder : NSObject

/* 初始化编码器 */
- (BOOL)initWithEncoder;

/* 编码 pcm->aac */
- (void)encoderWithPCMData:(NSData *)pcmData completion:(void(^)(uint8_t *out_buffer, size_t out_buffer_size))completion;

/* 释放编码器 */
- (void)releaseEncoder;

@end
