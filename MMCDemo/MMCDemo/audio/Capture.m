//
//  Capture.m
//  MMCDemo
//
//  Created by lijia8 on 2018/12/12.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import "Capture.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define QUEUE_BUFFER_SIZE 3      //输出音频队列缓冲个数
#define kDefaultBufferSize 2048     //缓冲区大小
#define kDefaultSampleRate 44100      //定义采样率为44100

static BOOL isRecording = NO;

@interface Capture() {
    AudioQueueRef _audioQueue;      //输出音频播放队列
    AudioStreamBasicDescription _recordFormat;
    AudioQueueBufferRef _audioBuffers[QUEUE_BUFFER_SIZE];      //输出音频缓存
}
@property (nonatomic, assign) BOOL isRecording;
@end

@implementation Capture

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//PlayAndRecord
        [[AVAudioSession sharedInstance] setActive:YES error:nil];//如果录音时同时需要播放媒体，那么必须加上这两行代码
        memset(&_recordFormat, 0, sizeof(_recordFormat));
        //采样率
        _recordFormat.mSampleRate = kDefaultSampleRate;
        //单声道
        _recordFormat.mChannelsPerFrame = 1;
        _recordFormat.mFormatID = kAudioFormatLinearPCM;
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 16;
        //8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
        //初始化音频输入队列
        AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
        //创建缓冲器
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++){
            AudioQueueAllocateBuffer(_audioQueue, kDefaultBufferSize, &_audioBuffers[i]);
            AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
        }
    }
    return self;
}

void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc) {
    if (inNumPackets > 0) {
        Capture *recorder = (__bridge Capture*)inUserData;
        [recorder processAudioBuffer:inBuffer withQueue:inAQ];
    }
    if (isRecording) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void)processAudioBuffer:(AudioQueueBufferRef)audioQueueBufferRef withQueue:(AudioQueueRef)audioQueueRef {
    NSMutableData *data = [NSMutableData dataWithBytes:audioQueueBufferRef->mAudioData length:audioQueueBufferRef->mAudioDataByteSize];
    if (data.length < kDefaultBufferSize) { //处理长度小于kDefaultBufferSize的情况,此处是补00
        Byte byte[] = {0x00};
        NSData *zeroData = [[NSData alloc] initWithBytes:byte length:1];
        for (NSUInteger i = data.length; i < kDefaultBufferSize; i++) {
            [data appendData:zeroData];
        }
    }
    [self.delegate returnCaptureData:data];
}

- (void)startRecord {
    // 开始录音
    AudioQueueStart(_audioQueue, NULL);
    isRecording = YES;
}

- (void)stopRecord {
    if (isRecording)
    {
        isRecording = NO;
        //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否
        AudioQueueStop(_audioQueue, true);
        //移除缓冲区,true代表立即结束录制，false代表将缓冲区处理完再结束
        AudioQueueDispose(_audioQueue, true);
    }
}

- (void)dealloc {
    _audioQueue = nil;
}

@end
