//
//  MCHandler.m
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import "MCHandler.h"

@interface MCHandler()
@property(nonatomic, strong) MCQueue *messages;
@property(nonatomic, strong) MCQueue *groupMessages;
@property(nonatomic, strong) MCQueue *serverAcks;
@end


@implementation MCHandler

- (id)init {
    if (self = [super init]) {
        self.messages = [[MCQueue alloc] init];
        self.groupMessages = [[MCQueue alloc] init];
        self.serverAcks = [[MCQueue alloc] init];
    }
    return self;
}

- (void)handleMessage:(NSArray<MIMCMessage*> *)packets user:(MCUser *)user {
    NSLog(@"handleMessage, RECV_MIMC_MESSAGE, packets=%@", packets);
    @try {
        [_messages addAll:packets];
        NSLog(@"handleMessage, MESSAGES_SIZE=%d", [_messages size]);
    } @catch (NSException * ex) {
        NSLog(@"handleMessage, Exception: %@, %@", ex.name, ex.reason);
        return;
    }
}

- (void)handleGroupMessage:(NSArray<MIMCGroupMessage*> *)packets {
    NSLog(@"handleGroupMessage, RECV_GROUP_MESSAGE");
    @try {
        [_groupMessages addAll:packets];
        NSLog(@"handleGroupMessage, GROUP_MESSAGES_SIZE=%d", [_groupMessages size]);
    } @catch (NSException * ex) {
        NSLog(@"handleGroupMessage, Exception: %@, %@", ex.name, ex.reason);
        return;
    }
}

- (void)handleUnlimitedGroupMessage:(MIMCGroupMessage *)mimcGroupMessage {
    NSLog(@"handleUnlimitedGroupMessage, receive unlimitedGroupMessage packet, packetId=%@, sequence=%lld, timestamp=%lld, fromAccount=%@, groupId=%lld, payload=%@", mimcGroupMessage.getPacketId, mimcGroupMessage.getSequence, mimcGroupMessage.getTimestamp, mimcGroupMessage.getFromAccount, mimcGroupMessage.getGroupId, mimcGroupMessage.getPayload);
}

- (void)handleServerAck:(NSString *)packetId sequence:(int64_t)sequence timestamp:(int64_t)timestamp errorMsg:(NSString *)errorMsg {
    NSLog(@"handleServerAck, ReceiveMessageAck, ackPacketId=%@, sequence=%lld, timestamp=%lld, errorMsg=%@", packetId, sequence, timestamp, errorMsg);
    @try {
        [_serverAcks push:packetId];
        NSLog(@"handleServerAck, SERVER_ACKS_SIZE=%d", [_serverAcks size]);
    } @catch (NSException * ex) {
        NSLog(@"handleServerAck, Exception: %@, %@", ex.name, ex.reason);
        return;
    }
}

- (void)handleSendMessageTimeout:(MIMCMessage *)message {
    NSLog(@"handleSendMessageTimeout, message.packetId=%@, message.sequence=%lld, message.timestamp=%lld, message.fromAccount=%@, message.toAccount=%@, message.payload=%@", message.getPacketId, message.getSequence, message.getTimestamp, message.getFromAccount, message.getToAccount, message.getPayload);
}

- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage {
    NSLog(@"handleSendGroupMessageTimeout, groupMessag.packetId=%@, groupMessag.sequence=%lld, groupMessage.timestamp=%lld, groupMessage.fromAccount=%@, groupMessage.groupId=%lld, groupMessag.payload=%@", groupMessage.getPacketId, groupMessage.getSequence, groupMessage.getTimestamp, groupMessage.getFromAccount, groupMessage.getGroupId, groupMessage.getPayload);
}

- (void)handleSendUnlimitedGroupMessageTimeout:(UCPacket *)ucPacket {
    NSLog(@"handleSendUnlimitedGroupMessageTimeout, ucPacket=%@", ucPacket);
}

- (NSString *)pollServerAck:(int64_t)timeoutMs {
    @try {
        NSString *packetId = [_serverAcks pop:timeoutMs];
        if (packetId.length == 0) {
            [NSThread sleepForTimeInterval:timeoutMs];
            packetId = [_serverAcks pop:timeoutMs];
        }
        NSLog(@"pollServerAck, SERVER_ACK_SIZE=%d", [_serverAcks size]);
        return packetId;
    } @catch (NSException * ex) {
        NSLog(@"pollServerAck, Exception: %@, %@", ex.name, ex.reason);
        return nil;
    }
}

- (MIMCMessage *)pollMessage:(int64_t)timeoutMs {
    @try
    {
        MIMCMessage *msg = [_messages pop:timeoutMs];
        if (msg == nil) {
            [NSThread sleepForTimeInterval:timeoutMs];
            msg = [_messages pop:timeoutMs];
        }
        NSLog(@"pollMessage, MESSAGE_SIZE=%d", [_messages size]);
        return msg;
    } @catch (NSException * ex) {
        NSLog(@"pollMessage, Exception: %@, %@", ex.name, ex.reason);
        return nil;
    }
}

- (MIMCGroupMessage *)pollGroupMessage:(int64_t)timeoutMs {
    @try
    {
        MIMCGroupMessage *msg = [_groupMessages pop:timeoutMs];
        if (msg == nil) {
            [NSThread sleepForTimeInterval:timeoutMs];
            msg = [_groupMessages pop:timeoutMs];
        }
        NSLog(@"pollGroupMessage, GROUP_MESSAGE_SIZE=%d", [_groupMessages size]);
        return msg;
    } @catch (NSException * ex) {
        NSLog(@"pollGroupMessage, Exception: %@, %@", ex.name, ex.reason);
        return nil;
    }
}

- (BOOL)clearQueue {
    [_messages clear];
    [_groupMessages clear];
    [_serverAcks clear];
    return true;
}

@end
