//
//  Decoder.h
//  MMCDemo
//
//  Created by lijia8 on 2018/12/13.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Decoder : NSObject

/* 初始化解码器 */
- (BOOL)initWithDecoder;

/* 解码 aac->pcm */
- (void)decoderWithAACData:(NSData *)aacData completion:(void(^)(uint8_t *out_buffer, size_t out_buffer_size))completion;

/* 释放解码器 */
- (void)releaseDecoder;

@end
