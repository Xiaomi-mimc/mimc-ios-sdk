//
//  Decoder.m
//  MMCDemo
//
//  Created by lijia8 on 2018/12/13.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import "Decoder.h"
#import <VideoToolbox/VideoToolbox.h>
#import "libavcodec/avcodec.h"
#import "libswscale/swscale.h"
#include <libavformat/avformat.h>
#include "libswresample/swresample.h"

@interface Decoder ()
/**
 * AVFormatContext：保存需要读入的文件的格式信息，比如流的个数以及流数据等
 * AVCodecCotext：保存了相应流的详细编码信息，比如视频的宽、高，编码类型等
 * pCodec：真正的编解码器，其中有编解码需要调用的函数
 * AVFrame：用于保存数据帧的数据结构，这里的两个帧分别是保存颜色转换前后的两帧图像（pcm）
 * AVPacket：解析文件时会将音/视频帧读入到packet中（aac）
 **/
@property (assign, nonatomic) AVFrame *avFrame;
@property (assign, nonatomic) AVCodec *avCodec;
@property (assign, nonatomic) AVCodecContext *avCodecContext;
@property (assign, nonatomic) AVPacket *avPacket;
@end

@implementation Decoder

- (BOOL)initWithDecoder {
    // 注册解码器
    avcodec_register_all();
    // 查找解码器
    self.avCodec = avcodec_find_decoder_by_name("libfdk_aac");
    if (!self.avCodec) {
        NSLog(@"Decoder not found!");
        return NO;
    }
    self.avCodecContext = avcodec_alloc_context3(self.avCodec);
    if (!self.avCodecContext) {
        NSLog(@"Could not allocate audio decode context!");
        return NO;
    }
    self.avCodecContext->codec_id = AV_CODEC_ID_AAC;
    self.avCodecContext->sample_fmt = AV_SAMPLE_FMT_S16;
    self.avCodecContext->codec_type = AVMEDIA_TYPE_AUDIO;
    self.avCodecContext->bit_rate = 32000;
    self.avCodecContext->sample_rate = 44100;
    self.avCodecContext->channel_layout = AV_CH_LAYOUT_MONO;
    self.avCodecContext->channels = av_get_channel_layout_nb_channels(self.avCodecContext->channel_layout);
    self.avCodecContext->thread_count = 2;
    
    self.avPacket = av_packet_alloc();
    if (!self.avPacket) {
        NSLog(@"Could not alloc packet!");
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    av_init_packet(self.avPacket);
    
    self.avFrame = av_frame_alloc();
    if (!self.avFrame) {
        NSLog(@"Could not alloc decoded frame!");
        av_packet_free(&_avPacket);
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    
    // 打开解码器
    if (avcodec_open2(self.avCodecContext, self.avCodec, NULL) < 0) {
        NSLog(@"Could not open decoder!");
        av_frame_free(&_avFrame);
        av_packet_free(&_avPacket);
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    return YES;
}

- (void)decoderWithAACData:(NSData *)aacData completion:(void(^)(uint8_t *out_buffer, size_t out_buffer_size))completion {
    if (aacData.length <= 0) {
        NSLog(@"Get aac data error!");
        return;
    }
    if (!self.avCodecContext || !self.avPacket) {
        NSLog(@"avCodecContext or avPacket is null!");
        return;
    }
    self.avPacket->data = (uint8_t *)aacData.bytes;
    self.avPacket->size = (int)aacData.length;
    
    if (self.avPacket->size > 0) {
        int ret = avcodec_send_packet(self.avCodecContext, self.avPacket);
        if (ret < 0) {
            NSLog(@"Error submitting the packet to the decoder, ret:%d", ret);
            return;
        }
        while (ret >= 0) {
            ret = avcodec_receive_frame(self.avCodecContext, self.avFrame);
            if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                return;
            }else if (ret < 0) {
                NSLog(@"Error during decoding. ret:%d", ret);
                return;
            }
            
            //回调给外层
            if (completion) {
                completion(self.avFrame->data[0], self.avFrame->linesize[0]);
            }
            av_frame_unref(self.avFrame);
        }
        
    }
}

- (void)releaseDecoder {
    if(self.avCodecContext) {
        avcodec_close(self.avCodecContext);
        avcodec_free_context(&_avCodecContext);
        self.avCodecContext = NULL;
    }
    if(self.avFrame) {
        av_frame_free(&_avFrame);
        self.avFrame = NULL;
    }
    if(self.avPacket) {
        av_packet_free(&_avPacket);
        self.avPacket = NULL;
    }
}

@end
