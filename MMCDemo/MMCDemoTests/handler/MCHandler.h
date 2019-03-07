//
//  MCHandler.h
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCUser.h"
#import "MIMCMessage.h"
#import "MIMCGroupMessage.h"
#import "MCQueue.h"

@interface MCHandler : NSObject<handleMessageDelegate>

- (id)init;
- (void)handleMessage:(NSMutableArray<MIMCMessage*> *)packets user:(MCUser *)user;
- (void)handleGroupMessage:(NSMutableArray<MIMCGroupMessage*> *)packets;
- (void)handleServerAck:(NSString *)packetId sequence:(int64_t)sequence timestamp:(int64_t)timestamp errorMsg:(NSString *)errorMsg;
- (void)handleUnlimitedGroupMessage:(MIMCGroupMessage *)mimcGroupMessage;

- (void)handleSendMessageTimeout:(MIMCMessage *)message;
- (void)handleSendGroupMessageTimeout:(MIMCGroupMessage *)groupMessage;
- (void)handleSendUnlimitedGroupMessageTimeout:(UCPacket *)ucPacket;

- (NSString *)pollServerAck:(int64_t)timeoutMs;
- (MIMCMessage *)pollMessage:(int64_t)timeoutMs;
- (MIMCGroupMessage *)pollGroupMessage:(int64_t)timeoutMs;
- (BOOL)clearQueue;
@end
