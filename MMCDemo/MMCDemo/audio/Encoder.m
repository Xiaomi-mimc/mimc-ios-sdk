//
//  Encoder.m
//  MMCDemo
//
//  Created by lijia8 on 2018/12/14.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import "Encoder.h"
#import <VideoToolbox/VideoToolbox.h>
#import "libavcodec/avcodec.h"
#import "libswscale/swscale.h"
#include <libavformat/avformat.h>
#include "libswresample/swresample.h"

@interface Encoder ()
/**
 * AVCodecCotext：解码器上下文,保存了相应流的详细编码信息，比如视频的宽、高，编码类型等
 * pCodec：解码器
 * AVFrame：AVFrame表示解码后的音/视频数据 pcm
 * AVPacket：AVPacket表示编码（即压缩）后的数据 aac
 *
 * avcodec_send_packet() 发送未解码数据
 * avcodec_receive_frame() 接收解码后的数据
 * avcodec_send_frame() 发送未编码的数据
 * avcodec_receive_packet() 接收编码后的数据
 * 在这4个函数中的返回值中，都会有两个错误AVERROR(EAGAIN)和AVERROR_EOF
 
 *
 **/
@property (assign, nonatomic) AVFrame *avFrame;
@property (assign, nonatomic) AVCodec *avCodec;
@property (assign, nonatomic) AVCodecContext *avCodecContext;
@property (assign, nonatomic) AVPacket *avPacket;
@end

@implementation Encoder

- (BOOL)initWithEncoder {
    // 注册编码器
    avcodec_register_all();
    // 查找编码器
    self.avCodec = avcodec_find_encoder_by_name("libfdk_aac");
    if (!self.avCodec) {
        NSLog(@"Encoder not found!");
        return NO;
    }
    self.avCodecContext = avcodec_alloc_context3(self.avCodec);
    if (!self.avCodecContext) {
        NSLog(@"Could not allocate audio encode context!");
        return NO;
    }
    self.avCodecContext->codec_id = AV_CODEC_ID_AAC;
    self.avCodecContext->sample_fmt = AV_SAMPLE_FMT_S16;
    if (!check_sample_fmt(self.avCodec, self.avCodecContext->sample_fmt)) {
        NSLog(@"Encoder does not support sample format %s", av_get_sample_fmt_name(self.avCodecContext->sample_fmt));
        avcodec_free_context(&_avCodecContext);
        return -1;
    }
    self.avCodecContext->codec_type = AVMEDIA_TYPE_AUDIO;
    self.avCodecContext->bit_rate = 32000;
    self.avCodecContext->sample_rate = 44100;
    self.avCodecContext->channel_layout = AV_CH_LAYOUT_MONO;
    self.avCodecContext->channels = av_get_channel_layout_nb_channels(self.avCodecContext->channel_layout);
    self.avCodecContext->thread_count = 2;
    
    self.avPacket = av_packet_alloc();
    if (!self.avPacket) {
        NSLog(@"Could not alloc encode packet!");
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    av_init_packet(self.avPacket);
    
    // 打开解码器
    if (avcodec_open2(self.avCodecContext, self.avCodec, NULL) < 0) {
        NSLog(@"Could not open encoder!");
        av_packet_free(&_avPacket);
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    
    //打开解码器后分配
    self.avFrame = av_frame_alloc();
    if (!self.avFrame) {
        NSLog(@"Could not allocate audio frame!");
        av_packet_free(&_avPacket);
        avcodec_close(self.avCodecContext);
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    self.avFrame->nb_samples = self.avCodecContext->frame_size;
    self.avFrame->format = self.avCodecContext->sample_fmt;
    self.avFrame->channel_layout = self.avCodecContext->channel_layout;
    
    int ret = av_frame_get_buffer(self.avFrame, 0);
    if (ret < 0) {
        NSLog(@"Could not allocate audio data buffers!");
        av_frame_free(&_avFrame);
        av_packet_free(&_avPacket);
        avcodec_close(self.avCodecContext);
        avcodec_free_context(&_avCodecContext);
        return NO;
    }
    return YES;
}

- (void)encoderWithPCMData:(NSData *)pcmData completion:(void(^)(uint8_t *out_buffer, size_t out_buffer_size))completion {
    if (pcmData.length <= 0) {
        NSLog(@"Get pcm data error!");
        return;
    }
    if (!self.avCodecContext || !self.avFrame) {
        NSLog(@"avCodecContext or avFrame is null!");
        return;
    }
    int ret = av_frame_make_writable(self.avFrame);
    if (ret < 0) {
        NSLog(@"Frame is not writable!");
        return;
    }
    
    Byte *pcmBytes = (Byte *)[pcmData bytes];
    ret = avcodec_fill_audio_frame(
                                   self.avFrame,
                                   self.avCodecContext->channels,
                                   self.avCodecContext->sample_fmt,
                                   (const uint8_t *)pcmBytes,
                                   (int)pcmData.length,
                                   0);
    if (ret < 0) {
        NSLog(@"Fill audio frame error!");
        NSLog(@"============%d", ret);
        return;
    }
    
    self.avPacket->data = NULL;
    self.avPacket->size = 0;
    ret = avcodec_send_frame(self.avCodecContext, self.avFrame);
    if (ret < 0) {
        NSLog(@"Error sending the frame to the encoder!");
        return;
    }
    while (ret >= 0) {
        ret = avcodec_receive_packet(self.avCodecContext, self.avPacket);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
            return;
        }else if (ret < 0) {
            NSLog(@"Error during encoding. ret:%d", ret);
            return;
        }
        
        //回调给外层
        if (completion) {
            completion(self.avPacket->data, self.avPacket->size);
        }
        av_packet_unref(self.avPacket);
    }
}

- (void)releaseEncoder {
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

int check_sample_fmt(const AVCodec *codec, enum AVSampleFormat sample_fmt) {
    const enum AVSampleFormat *p = codec->sample_fmts;
    while (*p != AV_SAMPLE_FMT_NONE) {
        NSLog(@"Encoder support sample format:%s", av_get_sample_fmt_name(*p));
        if (*p == sample_fmt)
            return 1;
        p++;
    }
    return 0;
}

@end
