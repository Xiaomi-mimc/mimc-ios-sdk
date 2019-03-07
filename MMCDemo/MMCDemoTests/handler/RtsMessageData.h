//
//  RtsMessageData.h
//  MIMCTest
//
//  Created by zhangdan on 2018/9/3.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIMCRtsDataType.h"
#import "MIMCRtsChannelType.h"

@interface RtsMessageData : NSObject
- (id)initWithFromAccount:(NSString *)fromAccount fromResource:(NSString *)fromResource chatId:(int64_t)chatId appContent:(NSData *)appContent;
- (id)initWithChatId:(int64_t)chatId accepted:(Boolean)accepted extraMsg:(NSString *)extraMsg;
- (id)initWithChatId:(int64_t)chatId extraMsg:(NSString *)extraMsg;
- (id)initWithChatId:(int64_t)chatId recvData:(NSData *)recvData dataType:(RtsDataType)dataType channelType:(RtsChannelType)channelType;

- (NSString *)getFromAccount;
- (NSString *)getFromResource;
- (int64_t)getChatId;
- (NSData *)getAppContent;
- (Boolean)isAccepted;
- (NSString *)getExtraMsg;
- (NSData *)getRecvData;
- (RtsDataType)getDataType;
- (RtsChannelType)getChannelType;
@end
