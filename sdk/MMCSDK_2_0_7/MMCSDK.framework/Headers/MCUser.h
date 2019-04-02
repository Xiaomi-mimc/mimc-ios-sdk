//
//  MCUser.h
//  MIMCSDK
//
//  Created by zhangdan on 2017/11/22.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objc/runtime.h"
#include <pthread.h>
#import "MIMCMessage.h"
#import "MIMCGroupMessage.h"
#import "MIMCLaunchedResponse.h"
#import "MIMCRtsDataType.h"
#import "MIMCRtsChannelType.h"
#import "MIMCLoggerWrapper.h"
#import "MIMCStreamConfig.h"
#import "MIMCServerAck.h"

@class XMDTransceiver;
@class MIMCConnection;
@class MCUser;
@class MIMCHistoryMessagesStorage;
@class UCPacket;
@class MIMCThreadSafeDic;
@class BindRelayResponse;

@protocol parseTokenDelegate <NSObject>
- (NSString *)parseProxyServiceToken:(NSData *)proxyResult;
@end

@protocol onlineStatusDelegate <NSObject>
- (void)statusChange:(MCUser *)user status:(int)status type:(NSString *)type reason:(NSString *)reason desc:(NSString *)desc;
@end

@protocol handleMessageDelegate <NSObject>
- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user;
- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets;
- (void)handleServerAck:(MIMCServerAck *)serverAck;
- (void)handleUnlimitedGroupMessage:(MIMCGroupMessage *)mimcGroupMessage;

- (void)handleSendMessageTimeout:(MIMCMessage *)message;
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleSendUnlimitedGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
@end

@protocol handleUCMessageDelegate <NSObject>
- (void)handleJoinUnlimitedGroupResp:(int64_t)topicId code:(int)code message:(NSString *)message context:(id)context;
- (void)handleQuitUnlimitedGroupResp:(int64_t)topicId code:(int)code message:(NSString *)message context:(id)context;
- (void)handleDismissUnlimitedGroup:(int64_t)topicId;

- (void)handleCreateUnlimitedGroup:(NSString *)topicId topicName:(NSString *)topicName success:(BOOL)success desc:(NSString *)desc context:(id)context;
- (void)handleDismissUnlimitedGroup:(BOOL)success desc:(NSString *)desc context:(id)context;
@end

@protocol rTSCallEventDelegate <NSObject>
- (MIMCLaunchedResponse *)onLaunched:(NSString *)fromAccount fromResource:(NSString *)fromResource callId:(int64_t)callId appContent:(NSData *)appContent;
- (void)onAnswered:(int64_t)callId accepted:(Boolean)accepted desc:(NSString *)desc; // 会话接通之后的回调
- (void)onClosed:(int64_t)callId desc:(NSString *)desc; // 会话被关闭的回调
- (void)handleData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType; // 接收到数据的回调
- (void)handleSendDataSuccess:(int64_t)callId dataId:(int)dataId context
                             :(void *)context; //发送数据成功的回调
- (void)handleSendDataFail:(int64_t)callId dataId:(int)dataId context
                          :(void *)context; //发送数据失败的回调
@end

typedef enum _OnlineStatus {
    Offline,
    Online
} OnlineStatus;

typedef enum _RelayLinkState {
    NOT_CREATED,
    BEING_CREATED,
    SUCC_CREATED
} RelayLinkState;

typedef enum _MIMCDataPriority {
    MIMC_P0,
    MIMC_P1,
    MIMC_P2,
} MIMCDataPriority;

static NSString *join(NSMutableDictionary *kvs) {
    if (kvs == nil) {
        return @"";
    }

    NSString *s = [[NSString alloc] init];
    for (NSString *key in kvs) {
        [s stringByAppendingFormat:@"%@:%@,", key, [kvs objectForKey:key]];
    }

    if (s.length > 1) {
        [s substringToIndex:s.length - 1];
    }
    return s;
}

@interface MCUser : NSObject

@property(nonatomic, weak) id<parseTokenDelegate> parseTokenDelegate;
@property(nonatomic, weak) id<onlineStatusDelegate> onlineStatusDelegate;
@property(nonatomic, weak) id<handleMessageDelegate> handleMessageDelegate;
@property(nonatomic, weak) id<handleUCMessageDelegate> handleUCMessageDelegate;
@property(nonatomic, weak) id<rTSCallEventDelegate> rTSCallEventDelegate;

- (BOOL)logout;
- (NSString *)pull;
- (BOOL)login;
- (BOOL)login:(BOOL)useCache;
- (void)setOnlineStatus:(OnlineStatus)status;
- (void)addCloudAttr:(NSString *)key value:(NSString *)value;
- (void)addClientAttr:(NSString *)key value:(NSString *)value;
- (NSString *)createPacketId;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload isStore:(Boolean)isStore;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendMessage:(NSString *)toAppAccount payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload isStore:(Boolean)isStore;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType isStore:(Boolean)isStore;
- (Boolean)sendPacket:(NSString *)msgId payload:(NSData *)payload msgType:(NSString *)msgType;
- (id)initWithAppId:(int64_t)appId andAppAccount:(NSString *)appAccount andAsynchFetchTokenRequest:(NSMutableURLRequest *)asynchFetchTokenRequest;
- (id)initWithAppId:(int64_t)appId andAppAccount:(NSString *)appAccount andResource:(NSString *)resource andAsynchFetchTokenRequest:(NSMutableURLRequest *)asynchFetchTokenRequest;
- (BOOL)isOnline;
- (void)destroy;
- (void)dealloc;
- (void)closeConnection;
- (void)handleUDPConnClosed:(int64_t)connId connCloseType:(int)connCloseType;

- (int64_t)dialCall:(NSString *)toAppAccount;
- (int64_t)dialCall:(NSString *)toAppAccount toResource:(NSString *)toResource;
- (int64_t)dialCall:(NSString *)toAppAccount appContent:(NSData *)appContent;
- (int64_t)dialCall:(NSString *)toAppAccount toResource:(NSString *)toResource appContent:(NSData *)appContent;
- (Boolean)sendRtsData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType dataPriority:(MIMCDataPriority)dataPriority canBeDropped:(Boolean)canBeDropped context:(void *)context;
- (Boolean)sendRtsData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType dataPriority:(MIMCDataPriority)dataPriority canBeDropped:(Boolean)canBeDropped resendCount:(int)resendCount context:(void *)context;
- (Boolean)sendRtsData:(int64_t)callId data:(NSData *)data dataType:(RtsDataType)dataType dataPriority:(MIMCDataPriority)dataPriority canBeDropped:(Boolean)canBeDropped resendCount:(int)resendCount channelType:(RtsChannelType)channelType context:(void *)context;

- (void)closeCall:(int64_t)callId;
- (void)closeCall:(int64_t)callId byeReason:(NSString *)byeReason;
- (void)clearLocalRelayLinkStateAndTs;

- (BOOL)createUnlimitedGroup:(NSString *)topicName context:(id)context;
- (BOOL)dismissUnlimitedGroup:(int64_t)topicId context:(id)context;
- (NSString *)joinUnlimitedGroup:(int64_t)topicId context:(id)context;
- (NSString *)quitUnlimitedGroup:(int64_t)topicId context:(id)context;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload isStore:(BOOL)isStore;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType;
- (NSString *)sendUnlimitedGroupMessage:(int64_t)topicId payload:(NSData *)payload bizType:(NSString *)bizType isStore:(BOOL)isStore;

- (int)getChid;
- (NSString *)getUuid;
- (NSString *)getResource;
- (NSString *)getSecurityKey;
- (NSString *)getToken;
- (int64_t)getAppId;
- (NSString *)getAppPackage;
- (NSString *)getAppAccount;
- (NSString *)getClientAttrs;
- (NSString *)getCloudAttrs;
- (MIMCConnection *)getConn;
- (OnlineStatus)getStatus;
- (int64_t)getLastLoginTimestamp;
- (int64_t)getLastCreateConnTimestamp;
- (int)getTryCreateConnCount;
- (MIMCHistoryMessagesStorage *)getHistoryMessagesStorage;
- (MIMCThreadSafeDic *)getCurrentCalls;
- (RelayLinkState)getRelayLinkState;
- (int64_t)getLatestLegalRelayConnStateTs;
- (int64_t)getRelayConnId;
- (short)getRelayControlStreamId;
- (short)getRelayVideoStreamId;
- (short)getRelayAudioStreamId;
- (BindRelayResponse *)getBindRelayResponse;
- (XMDTransceiver *)getXmdTransceiver;
- (NSMutableSet *)getUcTopicSet;
- (NSMutableDictionary *)getUcContextDic;
- (int64_t)getLastPingCallManagerTimestamp;
- (int64_t)getLastPingRelayTimestamp;
- (int)getMaxRtsCallCount;
- (int)getPacketLoss;
- (int64_t)getRegionBucke;
- (NSString *)getFeDomain;
- (NSString *)getRelayDomain;
- (int64_t)getRegionBucketFromCallSession:(int64_t)callId;

- (void)setChid:(int)chid;
- (void)setUuid:(NSString *)uuid;
- (void)setResource:(NSString *)resource;
- (void)setSecurityKey:(NSString *)securityKey;
- (void)setToken:(NSString *)token;
- (void)setLastLoginTimestamp:(int64_t)lastLoginTimestamp;
- (void)setLastCreateConnTimestamp:(int64_t)lastCreateConnTimestamp;
- (void)setTryCreateConnCount:(int)tryCreateConnCount;
- (void)setPingFlag:(BOOL)pingFlag;
- (void)setRelayLinkState:(RelayLinkState)relayLinkState;
- (void)setLatestLegalRelayConnStateTs:(int64_t)latestLegalRelayConnStateTs;
- (void)setRelayConnId:(int64_t)relayConnId;
- (void)setRelayControlStreamId:(short)relayControlStreamId;
- (void)setRelayVideoStreamId:(short)relayVideoStreamId;
- (void)setRelayAudioStreamId:(short)relayAudioStreamId;
- (void)setBindRelayResponse:(BindRelayResponse *)bindRelayResponse;
- (void)setLastPingCallManagerTimestamp:(int64_t)lastPingCallManagerTimestamp;
- (void)setLastPingRelayTimestamp:(int64_t)lastPingRelayTimestamp;
- (void)setPacketLoss:(int)packetLoss;
- (void)setRegionBucket:(int64_t)regionBucket;
- (void)setFeDomain:(NSString *)feDomain;
- (void)setRelayDomain:(NSString *)relayDomain;

- (void)initAudioStreamConfig:(MIMCStreamConfig *)audioStreamConfig;
- (MIMCStreamConfig *)getAudioStreamConfig;
- (void)initVideoStreamConfig:(MIMCStreamConfig *)videoStreamConfig;
- (MIMCStreamConfig *)getVideoStreamConfig;
- (void)setSendBufferSize:(int)size;
- (int)getSendBufferSize;
- (void)clearSendBuffer;
- (float)getSendBufferUsageRate;
- (void)setRecvBufferSize:(int)size;
- (int)getRecvBufferSize;
- (void)clearRecvBuffer;
- (float)getRecvBufferUsageRate;

+ (void)setMIMCLogSwitch:(BOOL)logSwitch;
+ (void)setMIMCLogLevel:(MIMCLogLevel)level;
@end
