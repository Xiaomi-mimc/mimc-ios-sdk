//
//  RtsMessageData.m
//  MIMCTest
//
//  Created by zhangdan on 2018/9/3.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import "RtsMessageData.h"

@interface RtsMessageData()
@property(nonatomic) NSString *fromAccount;
@property(nonatomic) NSString *fromResource;
@property(nonatomic) NSString *extraMsg;
@property(nonatomic) int64_t chatId;
@property(nonatomic) Boolean accepted;
@property(nonatomic) NSData *appContent;
@property(nonatomic) NSData *recvData;
@property(nonatomic) RtsDataType dataType;
@property(nonatomic) RtsChannelType channelType;
@end

@implementation RtsMessageData
- (id)initWithFromAccount:(NSString *)fromAccount fromResource:(NSString *)fromResource chatId:(int64_t)chatId appContent:(NSData *)appContent {
    if (self = [super init]) {
        self.fromAccount = fromAccount;
        self.fromResource = fromResource;
        self.chatId = chatId;
        self.appContent = appContent;
    }
    return self;
}

- (id)initWithChatId:(int64_t)chatId accepted:(Boolean)accepted extraMsg:(NSString *)extraMsg {
    if (self = [super init]) {
        self.chatId = chatId;
        self.accepted = accepted;
        self.extraMsg = extraMsg;
    }
    return self;
}

- (id)initWithChatId:(int64_t)chatId extraMsg:(NSString *)extraMsg {
    if (self = [super init]) {
        self.chatId = chatId;
        self.extraMsg = extraMsg;
    }
    return self;
}

- (id)initWithChatId:(int64_t)chatId recvData:(NSData *)recvData dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType {
    if (self = [super init]) {
        self.chatId = chatId;
        self.recvData = recvData;
        self.dataType = dataType;
        self.channelType = channelType;
    }
    return self;
}

- (NSString *)getFromAccount {
    return self.fromAccount;
}

- (NSString *)getFromResource {
    return self.fromResource;
}

- (int64_t)getChatId {
    return self.chatId;
}

- (NSData *)getAppContent {
    return self.appContent;
}

- (Boolean)isAccepted {
    return self.accepted;
}

- (NSString *)getExtraMsg {
    return self.extraMsg;
}

- (NSData *)getRecvData {
    return self.recvData;
}

- (RtsDataType)getDataType {
    return self.dataType;
}

- (RtsChannelType)getChannelType {
    return self.channelType;
}
@end
