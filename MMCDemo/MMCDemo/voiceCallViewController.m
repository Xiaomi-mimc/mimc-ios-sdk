//
//  voiceCallViewController.m
//  MMCDemo
//
//  Created by zhangdan on 2018/7/31.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import "voiceCallViewController.h"
#import "audio/Decoder.h"
#import "proto/AV.pbobjc.h"
#import "audio/Encoder.h"
#import "XMUserManager.h"
#import "AudioThreadSafeQueue.h"
#import "audio/Capture.h"
#import "audio/Player.h"

#define MAINVIEW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define MAINVIEW_WIDTH ([[UIScreen mainScreen] bounds].size.width)


@interface voiceCallViewController()<CaptureDelegate, OnCallStateDelegate>
@property(nonatomic, strong) XMUserManager *userManager;
@property(nonatomic, strong) UIButton *answerButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIButton *hangUpButton;
@property(nonatomic, strong) UILabel *receiverNameLabel;
@property(nonatomic, strong) UILabel *audioConnStateLabel;

@property(nonatomic, strong) Decoder *decoder;
@property(nonatomic, strong) Encoder *encoder;
@property(nonatomic, strong) Capture *caputer;
@property(nonatomic, strong) Player *player;
@property(nonatomic) BOOL isEncode;
@property(nonatomic) BOOL isDecode;
@property(nonatomic) int64_t sequence;
@property(nonatomic, strong) AudioThreadSafeQueue *encodeQueue;
@property(nonatomic, strong) AudioThreadSafeQueue *decodeQueue;
@property(nonatomic) NSThread *encodeThread;
@property(nonatomic) NSThread *decodeThread;

@end

@implementation voiceCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showVoiceCallInfo];
    [self initWithAudio];
}

- (void)dealloc {
    NSLog(@"------dealloc------");
}

- (void)initWithAudio {
    self.decoder = [[Decoder alloc] init];
    self.isDecode = [self.decoder initWithDecoder];
    self.encoder = [[Encoder alloc] init];
    self.isEncode = [self.encoder initWithEncoder];
    self.caputer = [[Capture alloc] init];
    self.caputer.delegate = self;
    self.player = [[Player alloc] init];
    self.userManager = [XMUserManager sharedInstance];
    self.userManager.OnCallStateDelegate = self;
    self.sequence = 0;
    
    self.encodeQueue = [[AudioThreadSafeQueue alloc] init];
    self.decodeQueue = [[AudioThreadSafeQueue alloc] init];
    self.encodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(encodeThreadFunc) object:nil];
    [self.encodeThread setName:@"encodeThread"];
    [self.encodeThread start];
    self.decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeThreadFunc) object:nil];
    [self.decodeThread setName:@"decodeThread"];
    [self.decodeThread start];
}

- (void)showVoiceCallInfo {
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.frame = CGRectMake(0, 0, MAINVIEW_WIDTH, MAINVIEW_HEIGHT);
    
    _receiverNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((MAINVIEW_WIDTH - 100)/2, 100, 100, 30)];
    [_receiverNameLabel setFont:[UIFont systemFontOfSize:20]];
    [_receiverNameLabel setTextColor:[UIColor whiteColor]];
    _receiverNameLabel.text = self.receiver;
    _receiverNameLabel.textAlignment = NSTextAlignmentCenter;
    
    _audioConnStateLabel = [[UILabel alloc] initWithFrame:CGRectMake((MAINVIEW_WIDTH - 200)/2, 140, 200, 30)];
    [_audioConnStateLabel setFont:[UIFont systemFontOfSize:15]];
    [_audioConnStateLabel setTextColor:[UIColor whiteColor]];
    _audioConnStateLabel.text = self.audioConnState;
    _audioConnStateLabel.textAlignment = NSTextAlignmentCenter;
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _cancelButton.frame = CGRectMake((MAINVIEW_WIDTH - 50)/2, 500, 50, 30);
    _cancelButton.backgroundColor = [UIColor redColor];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
    
    _hangUpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _hangUpButton.frame = CGRectMake(50, 500, 50, 30);
    _hangUpButton.backgroundColor = [UIColor redColor];
    [_hangUpButton setTitle:@"挂断" forState:UIControlStateNormal];
    [_hangUpButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_hangUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_hangUpButton addTarget:self action:@selector(hangUp) forControlEvents:UIControlEventTouchDown];
    
    _answerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _answerButton.frame = CGRectMake(MAINVIEW_WIDTH - 100, 500, 50, 30);
    _answerButton.backgroundColor = [UIColor greenColor];
    [_answerButton setTitle:@"接听" forState:UIControlStateNormal];
    [_answerButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_answerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_answerButton addTarget:self action:@selector(answer) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:_cancelButton];
    [self.view addSubview:_hangUpButton];
    [self.view addSubview:_answerButton];
    [self.view addSubview:_receiverNameLabel];
    [self.view addSubview:_audioConnStateLabel];
    
    if (self.numButton == CALL_SENDER) {
        _hangUpButton.hidden = YES;
        _answerButton.hidden = YES;
    }
    if (self.numButton == CALL_RECEIVER) {
        _cancelButton.hidden = YES;
    }
}

- (void)answer {
    if (self.callBackBlock) {
        self.callBackBlock(STATE_AGREE);
    }
    
    [self.caputer startRecord];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cancelButton setTitle:@"挂断" forState:UIControlStateNormal];
        self.answerButton.hidden = YES;
        self.hangUpButton.hidden = YES;
        self.cancelButton.hidden = NO;
        self.audioConnStateLabel.text = @"正在通话中...";
    });
}

- (void)cancel {
    [self.caputer stopRecord];
    [self.userManager.getUser closeCall:self.callId];
    self.callId = CALLID_INVALID;
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf freeCompletion];
    }];
}

- (void)hangUp {
    if (self.callBackBlock) {
        self.callBackBlock(STATE_REJECT);
    }
    
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        [weakSelf freeCompletion];
    }];
}

- (void)onAnswered:(int64_t)callId accepted:(BOOL)accepted desc:(NSString *)desc {
    NSLog(@"onAnswered, callId=%lld, accepted=%d, desc=%@", callId, accepted, desc);
    
    if (accepted == 1) {
        [self.caputer startRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.audioConnStateLabel.text = @"正在通话中...";
            [self.cancelButton setTitle:@"挂断" forState:UIControlStateNormal];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(self) weakSelf = self;
            [self dismissViewControllerAnimated:NO completion:^{
                [weakSelf freeCompletion];
            }];
        });
    }
}

- (void)onData:(int64_t)callId fromAccount:(NSString *)fromAccount resource:(NSString *)resource data:(NSData *)data dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType {
    NSLog(@"onData, callId=%lld, fromAccount=%@, resource=%@, data=%@, dataType=%d, channelType=%d", callId, fromAccount, resource, data, dataType, channelType);
    self.callId = callId;
    [self.decodeQueue push:data];
}

- (void)onClosed:(int64_t)callId desc:(NSString *)desc {
    NSLog(@"onClosed, callId=%lld, desc=%@", callId, desc);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callId != CALLID_INVALID) {
            __weak typeof(self) weakSelf = self;
            [self dismissViewControllerAnimated:NO completion:^{
                [weakSelf freeCompletion];
            }];
        }
    });
}

- (void)freeCompletion {
    [self.caputer stopRecord];
    [self.encodeThread cancel];
    [self.decodeThread cancel];
//    [self.encoder releaseEncoder];
//    [self.decoder releaseDecoder];
}

- (void)returnCaptureData:(NSMutableData *)data {
    NSLog(@"before pcmData=%@, pcmData.length=%lu", data, (unsigned long)data.length);
    [self.encodeQueue push:data];
}

- (void)encodeThreadFunc {
    while (![self.encodeThread isCancelled]) {
        @try {
            if (!self.isEncode) {
                NSLog(@"encoder error!");
                continue;
            }
            NSMutableData *data = [self.encodeQueue pop];
            if (data == nil) {
                usleep(1000);
                continue;
            }
            __weak typeof(self) weakSelf = self;
            [self.encoder encoderWithPCMData:data completion:^(uint8_t * _Nonnull out_buffer, size_t out_buffer_size) {
                NSData *aacData = [NSData dataWithBytes:(const void *)out_buffer length:out_buffer_size];
                NSLog(@"aacData=%@, aacData.length=%lu", aacData, (unsigned long)aacData.length);
                
                MIMCRtsPacket *audioPacket = [[MIMCRtsPacket alloc] init];
                audioPacket.type = MIMC_RTS_TYPE_Audio;
                audioPacket.codecType = MIMC_RTS_CODEC_TYPE_Ffmpeg;
                audioPacket.payload = aacData;
                audioPacket.sequence = ++weakSelf.sequence;
                
                if ([weakSelf.userManager.getUser sendRtsData:weakSelf.callId data:[audioPacket data] dataType:AUDIO dataPriority:MIMC_P0 canBeDropped:NO resendCount:0 channelType:RELAY context:NULL] != -1) {
                    NSLog(@"sendRtsData success");
                    return;
                }
                NSLog(@"sendRtsData fail");
                [weakSelf.caputer stopRecord];
            }];
        } @catch (NSException *exception) {
            NSLog(@"encodeThreadFunc, Exception: %@, %@", exception.name, exception.reason);
            return;
        }
    }
    return;
}

- (void)decodeThreadFunc {
    while (![self.decodeThread isCancelled]) {
        @try {
            if (!self.isDecode) {
                NSLog(@"decoder error!");
                continue;
            }
            if ([self.decodeQueue getQueueCount] > 12) {
                [self.decodeQueue clear];
                continue;
            }
            NSData *data = [self.decodeQueue pop];
            if (data == nil) {
                usleep(1000);
                continue;
            }
            MIMCRtsPacket *audio = [MIMCRtsPacket parseFromData:data error:nil];
            __weak typeof(self) weakSelf = self;
            [self.decoder decoderWithAACData:audio.payload completion:^(uint8_t *out_buffer, size_t out_buffer_size) {
                NSData *pcmData = [NSData dataWithBytes:(const void *)out_buffer length:out_buffer_size];
                NSLog(@"after pcmData=%@, pcmData.length=%lu", pcmData, (unsigned long)pcmData.length);
                [weakSelf.player playWithData:pcmData];
            }];
        } @catch (NSException *exception) {
            NSLog(@"decodeThreadFunc, Exception: %@, %@", exception.name, exception.reason);
            return;
        }
    }
    return;
}

@end
