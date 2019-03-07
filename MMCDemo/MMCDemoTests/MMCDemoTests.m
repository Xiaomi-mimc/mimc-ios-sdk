//
//  MMCDemoTests.m
//  MMCDemoTests
//
//  Created by zhangdan on 2018/9/25.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCHandler.h"
#import "MCToken.h"
#import "MCStatus.h"
#import "MCUser.h"
#import "MCHttpRequest.h"
#import "RtsPerformanceHandler.h"
#import "RtsPerformanceData.h"

@interface MMCDemoTests : XCTestCase
@property(nonatomic, strong) MCUser *rtsUser1;
@property(nonatomic, strong) MCUser *rtsUser2;

@property(nonatomic) NSString *account1;
@property(nonatomic) NSString *account2;

@property(nonatomic, strong) MCToken *fetchToken1;
@property(nonatomic, strong) MCStatus *onlineStatus1;
@property(nonatomic, strong) MCHandler *handleMessage1;
@property(nonatomic, strong) MCToken *fetchToken2;
@property(nonatomic, strong) MCStatus *onlineStatus2;
@property(nonatomic, strong) MCHandler *handleMessage2;

@property(nonatomic, strong) RtsPerformanceHandler *callEventHandler1;
@property(nonatomic, strong) RtsPerformanceHandler *callEventHandler2;
@end

@implementation MMCDemoTests

- (void)setUp {
    [super setUp];
    
    NSURL *url = [NSURL URLWithString:@"https://mimc.chat.xiaomi.net/api/account/token"];
    int64_t appId = 2882303761517669588;
    NSString *appKey = @"5111766983588";
    NSString *appSecret = @"b0L3IOz/9Ob809v8H2FbVg==";
    
    _account1 = @"rts_performance_account01";
    _account2 = @"rts_performance_account02";
    
    NSMutableURLRequest *rtsRequest1 = [MCHttpRequest generateRequest:url appId:appId appKey:appKey appSecret:appSecret appAccount:_account1];
    _rtsUser1 = [[MCUser alloc] initWithAppAccount:_account1 andAsynchFetchTokenRequest:rtsRequest1];
    
    self.fetchToken1 = [[MCToken alloc] init];
    self.onlineStatus1 = [[MCStatus alloc] init];
    self.handleMessage1 = [[MCHandler alloc] init];
    self.callEventHandler1 = [[RtsPerformanceHandler alloc] init];
    
    _rtsUser1.parseTokenDelegate = _fetchToken1;
    _rtsUser1.onlineStatusDelegate = _onlineStatus1;
    _rtsUser1.handleMessageDelegate = _handleMessage1;
    
    NSMutableURLRequest *rtsRequest2 = [MCHttpRequest generateRequest:url appId:appId appKey:appKey appSecret:appSecret appAccount:_account2];
    _rtsUser2 = [[MCUser alloc] initWithAppAccount:_account2 andAsynchFetchTokenRequest:rtsRequest2];
    
    self.fetchToken2 = [[MCToken alloc] init];
    self.onlineStatus2 = [[MCStatus alloc] init];
    self.handleMessage2 = [[MCHandler alloc] init];
    self.callEventHandler2 = [[RtsPerformanceHandler alloc] init];
    
    _rtsUser2.parseTokenDelegate = _fetchToken2;
    _rtsUser2.onlineStatusDelegate = _onlineStatus2;
    _rtsUser2.handleMessageDelegate = _handleMessage2;
}

- (void)tearDown {
    
    [super tearDown];
}

// 测试性能代码1
- (void)testPeformance {
    int dataSizeKB = 50;
    int speedKB = 200;
    int durationSec = 100;
    [self peformanceTest:_rtsUser1 callEventHandler1:_callEventHandler1 user2:_rtsUser2 callEventHandler2:_callEventHandler2 dataSizeKB:dataSizeKB dataSpeedKB:speedKB durationSec:durationSec];
}

// 测试性能代码2
- (void)testRtsEfficiency {
    int runCount = 5;
    int dataSize = 100 *1024;
    NSMutableDictionary *timeRecords = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < runCount; i++) {
        [self efficiencyTest:_rtsUser1 callEventHandler1:_callEventHandler1 user2:_rtsUser2 callEventHandler2:_callEventHandler2 idx:i dataSize:dataSize timeRecords:timeRecords];
    }
    
    int64_t sumLoginTime1 = 0;
    int64_t sumLoginTime2 = 0;
    int64_t sumDiaCallTime = 0;
    int64_t sumRecvDataTime = 0;
    for (NSString *key in [timeRecords allKeys]) {
        NSLog(@"testRtsEfficiency, TEST_TIME=%d, DATA SIZE=%dKB, loginTime1=%lld ms, loginTime2=%lld ms, dialCallTime=%lld ms, recvDataTime=%lld", [key intValue], dataSize / 1024, [[timeRecords objectForKey:key] getLoginTime1], [[timeRecords objectForKey:key] getLoginTime2], [[timeRecords objectForKey:key] getDiaCallTime], [[timeRecords objectForKey:key] getRecvDataTime]);
        sumLoginTime1 += [[timeRecords objectForKey:key] getLoginTime1];
        sumLoginTime2 += [[timeRecords objectForKey:key] getLoginTime2];
        sumDiaCallTime += [[timeRecords objectForKey:key] getDiaCallTime];
        sumRecvDataTime += [[timeRecords objectForKey:key] getRecvDataTime];
    }
    
    NSLog(@"testRtsEfficiency, TEST: runCount=%d, DATA SIZE=%d KB, avgLoginTime1=%lld ms, avgLoginTime2=%lld ms, avgDiaCallTime=%lld ms, avgRecvDataTime=%lld ms", runCount, dataSize / 1024, sumLoginTime1 / runCount, sumLoginTime2 / runCount, sumDiaCallTime / runCount, sumRecvDataTime / runCount);
}

- (void)efficiencyTest:(MCUser *)user1 callEventHandler1:(RtsPerformanceHandler *)callEventHandler1 user2:(MCUser *)user2 callEventHandler2:(RtsPerformanceHandler *)callEventHandler2 idx:(int)idx dataSize:(int)dataSize timeRecords:(NSMutableDictionary *)timeRecords {
    int64_t t0, t1, t2, t3, t4, t5, t6;
    
    NSData *sendData = [[self randomStringWithLength:dataSize] dataUsingEncoding:NSUTF8StringEncoding];
    
    user1.rTSCallEventDelegate = callEventHandler1;
    user2.rTSCallEventDelegate = callEventHandler2;
    
    [callEventHandler1 clear];
    [callEventHandler2 clear];
    
    t0 = [[NSDate date] timeIntervalSince1970]*1000;
    t1 = [[NSDate date] timeIntervalSince1970]*1000;
    t2 = [[NSDate date] timeIntervalSince1970]*1000;
    
    NSMutableArray *offlineUuids = [[NSMutableArray alloc] init];
    [offlineUuids addObject:user1.getAppAccount];
    [offlineUuids addObject:user2.getAppAccount];
    NSLog(@"efficiencyTest, Test %d timeStamp1 user start login=%lld", idx + 1, t0);
    
    [user1 login];
    [user2 login];
    
    for (int j = 0; j < 5000; j++) {
        if (offlineUuids.count == 0) break;
        
        if ([offlineUuids containsObject:user1.getAppAccount] && user1.isOnline) {
            [offlineUuids removeObject:user1.getAppAccount];
            t1 = [[NSDate date] timeIntervalSince1970]*1000;
        }
        
        if ([offlineUuids containsObject:user2.getAppAccount] && user2.isOnline) {
            [offlineUuids removeObject:user2.getAppAccount];
            t2 = [[NSDate date] timeIntervalSince1970]*1000;
        }
        
        [NSThread sleepForTimeInterval:0.001];
    }
    NSLog(@"efficiencyTest, Test %d timeStamp1 user finish login, cost=%f", idx, [[NSDate date] timeIntervalSince1970]*1000 - t0);
    
    XCTAssertTrue([user1 isOnline], @"efficiencyTest, LOGIN FAILED");
    XCTAssertTrue([user2 isOnline], @"efficiencyTest, LOGIN FAILED");
    
    t3 = [[NSDate date] timeIntervalSince1970]*1000;
    int64_t chatId = [user1 dialCall:user2.getAppAccount];
    
    for (int j = 0; j < 5000; j++) {
        if ([callEventHandler1 getMsgSize:2] > 0) {
            break;
        }
        [NSThread sleepForTimeInterval:0.001];
    }
    t4 = [[NSDate date] timeIntervalSince1970]*1000;
    
    XCTAssertEqualObjects([[callEventHandler1 pollCreateResponse:3.0] getExtraMsg], @"LAUNCH_OK", @"efficiencyTest, DIACALL FAILEDE");
    
    
    t5 = [[NSDate date] timeIntervalSince1970]*1000;
    XCTAssertTrue([user1 sendRtsData:chatId data:sendData dataType:AUDIO channelType:RELAY], @"efficiencyTest, SEND DATA FAILED");
    
    for (int j = 0; j < 5000; j++) {
        if ([callEventHandler2 getMsgSize:4] > 0) {
            break;
        }
        [NSThread sleepForTimeInterval:0.001];
    }
    
    t6 = [[NSDate date] timeIntervalSince1970]*1000;
    XCTAssertNotEqual(0, [callEventHandler2 getMsgSize:4], @"efficiencyTest, DATA LOST");
    
    MIMCThreadSafeDic *recvData = [callEventHandler2 pollDataInfo];
    XCTAssertTrue([[recvData.getDic allKeys] containsObject:[[NSNumber numberWithInt:[self byteArrayToInt:sendData]] stringValue]], @"efficiencyTest, RECEIVE DATA NOT MATCH");
    
    [self closeCallPeformance:chatId from:user1 callEventHandlerFrom:callEventHandler1 callEventHandlerTo:callEventHandler2];
    
    [timeRecords setObject:[[RtsPerformanceData alloc] initWithLoginTime1:t1 - t0 loginTime2:t2 - t0 diaCallTime:t4 - t3 recvDataTime:t6 - t5] forKey:[[NSNumber numberWithInt:idx] stringValue]];
}

- (void)peformanceTest:(MCUser *)user1 callEventHandler1:(RtsPerformanceHandler *)callEventHandler1 user2:(MCUser *)user2 callEventHandler2:(RtsPerformanceHandler *)callEventHandler2 dataSizeKB:(int)dataSizeKB dataSpeedKB:(int)dataSpeedKB durationSec:(int)durationSec {
    int sendFailed = 0;
    int lost = 0;
    int dataError = 0;
    int time0To50 = 0;
    int time51To100 = 0;
    int time101To150 = 0;
    int time151To200 = 0;
    int time201To300 = 0;
    int time301To400 = 0;
    int time401To500 = 0;
    int time501To1000 = 0;
    int time1001More = 0;
    
    MIMCThreadSafeDic *sendDatas = [[MIMCThreadSafeDic alloc] init];
    
    [self logInPeformance:user1 callEventHandler:callEventHandler1];
    [self logInPeformance:user2 callEventHandler:callEventHandler2];
    
    int64_t chatId = [self createCallPeformance:user1 callEventHandlerFrom:callEventHandler1 to:user2 callEventHandlerTo:callEventHandler2];
    
    int COUNT = (int)((double)(durationSec * dataSpeedKB) / dataSizeKB);
    
    for (int dataId = 0; dataId < COUNT; dataId++) {
        NSData *sendData = [[self randomStringWithLength:dataSizeKB * 1024 - 4] dataUsingEncoding:NSUTF8StringEncoding];
        sendData = [self byteMerge:[self intToByteArray:dataId] b2:sendData];
        
        if ([user1 sendRtsData:chatId data:sendData dataType:AUDIO channelType:RELAY]) {
            [sendDatas put:[[NSNumber numberWithInt:dataId] stringValue] value:[[RtsPerformanceData alloc] initWithDataByte:sendData dataTime:[[NSDate date] timeIntervalSince1970]*1000]];
        }
        
        [NSThread sleepForTimeInterval:0.25];
    }
    
    [NSThread sleepForTimeInterval:5.0];
    MIMCThreadSafeDic *recvDatas = [callEventHandler2 pollDataInfo];
    [self closeCallPeformance:chatId from:user1 callEventHandlerFrom:callEventHandler1 callEventHandlerTo:callEventHandler2];
    
    for (int i = 0; i < COUNT; i++) {
        if (![[sendDatas.getDic allKeys] containsObject:[[NSNumber numberWithInt:i] stringValue]]) {
            NSLog(@"peformanceTest, DATA_ID=%d, SEND FAILED", i);
            sendFailed++;
        } else if (![[recvDatas.getDic allKeys] containsObject:[[NSNumber numberWithInt:i] stringValue]]) {
            NSLog(@"peformanceTest, DATA_ID=%d, LOST", i);
            lost++;
        } else if (![[[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getData] isEqual:[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getData]]) {
            NSLog(@"peformanceTest, DATA_ID=%d, RECEIVE DATA NOT MATCH", i);
            dataError++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 50) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time0To50++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 100) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time51To100++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 150) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time101To150++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 200) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time151To200++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 300) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time201To300++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 400) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time301To400++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 500) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time401To500++;
        } else if ((int)[[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] <= 1000) {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time501To1000++;
        } else {
            NSLog(@"peformanceTest, DATA_ID=%d, %lld-%lld=%lld", i, [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime], [[recvDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime] - [[sendDatas.getDic objectForKey:[[NSNumber numberWithInt:i] stringValue]] getDataTime]);
            time1001More++;
        }
    }
    
    NSLog(@"peformanceTest, PERFORMANCE TEST RESULT: SEND=%d DATAS DURING %d s, DATA SIZE=%dKB, SPEED=%dKB/S, FAILED=%d, LOST=%d, DATA ERROR=%d, RECV_TIME(0, 50ms]=%d, RECV_TIME(50, 100ms]=%d, RECV_TIME(100, 150ms]=%d, RECV_TIME(150, 200ms]=%d, RECV_TIME(200, 300ms]=%d, RECV_TIME(300, 400ms]=%d, RECV_TIME(400, 500ms]=%d, RECV_TIME(500, 1000ms]=%d, RECV_TIME 1000+ms=%d", COUNT, durationSec, dataSizeKB, dataSpeedKB, sendFailed, lost, dataError, time0To50, time51To100, time101To150, time151To200, time201To300, time301To400, time401To500, time501To1000, time1001More);
}

- (NSData *)intToByteArray:(int)n {
    char *b = (char *)malloc(4);
    b[0] = (char) ((n >> 24) & 0xFF);
    b[1] = (char) ((n >> 16) & 0xFF);
    b[2] = (char) ((n >> 8) & 0xFF);
    b[3] = (char) (n & 0xFF);
    
    NSData *res = [[NSData alloc] initWithBytes:b length:4];
    free(b);
    b = NULL;
    return res;
}

- (int)byteArrayToInt:(NSData *)b {
    char *bStr = (char *)[b bytes];
    
    return (bStr[3] & 0xFF) | (bStr[2] & 0xFF) << 8 | (bStr[1] & 0xFF) << 16 | (bStr[0] & 0xFF) << 24;
}

- (NSData *)byteMerge:(NSData *)b1 b2:(NSData *)b2 {
    NSMutableData *b3 = [[NSMutableData alloc] initWithData:b1];
    [b3 appendData:b2];
    return b3;
}

- (void)logInPeformance:(MCUser *)user callEventHandler:(RtsPerformanceHandler *)callEventHandler {
    int64_t beforeLoginTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
    user.rTSCallEventDelegate = callEventHandler;
    
    [user login];
    NSLog(@"logInPeformance, user=%@, account=%@, uuid=%@, resource=%@", user, user.getAppAccount, user.getUuid, user.getResource);
    
    while([[NSDate date] timeIntervalSince1970]*1000 - beforeLoginTimestamp < 5000 && ![user isOnline]) {
        [NSThread sleepForTimeInterval:0.05];
    }
    XCTAssertTrue([user isOnline], @"logInPeformance, LOGIN FAILED");
    
    if (callEventHandler != nil) {
        NSLog(@"logInPeformance, CLEAR CALLEVENTHANDLER OF UUID:%@", user.getUuid);
        [callEventHandler clear];
    }
}

- (int64_t)createCallPeformance:(MCUser *)from callEventHandlerFrom:(RtsPerformanceHandler *)callEventHandlerFrom to:(MCUser *)to callEventHandlerTo:(RtsPerformanceHandler *)callEventHandlerTo {
    int64_t chatId = [from dialCall:to.getAppAccount];
    XCTAssertTrue(chatId != -1, @"createCallPeformance, CHAT_ID IS -1");
    [NSThread sleepForTimeInterval:1.0];
    
    RtsMessageData *inviteRequest = [callEventHandlerTo pollInviteRequest:1.0];
    XCTAssertNotNil(inviteRequest, @"createCallPeformance, INVITE_REQUEST IS NIL");
    XCTAssertTrue(chatId == inviteRequest.getChatId, @"createCallPeformance, CHAT_ID NOT MATCH IN INVITE_REQUEST");
    XCTAssertEqualObjects(from.getAppAccount, inviteRequest.getFromAccount, @"createCallPeformance, APP_ACCOUNT NOT MATCH IN INVITE_REQUES");
    XCTAssertEqualObjects(from.getResource, inviteRequest.getFromResource, @"createCallPeformance, RESOURCE NOT MATCH IN INVITE_REQUES");
    XCTAssertTrue(inviteRequest.getAppContent.length == 0, @"createCallPeformance, APP_CONTENT NOT MATCH");
    
    RtsMessageData *createResponse = [callEventHandlerFrom pollCreateResponse:1.0];
    XCTAssertNotNil(createResponse, @"createCallPeformance, CREATE_RESPONSE IS NIL");
    XCTAssertTrue(chatId == createResponse.getChatId, @"createCallPeformance, CHAT_ID NOT MATCH IN CREATE_RESPONSE");
    XCTAssertTrue(createResponse.isAccepted, @"createCallPeformance, IS_ACCEPTED NOT MATCH IN CREATE_RESPONSE");
    XCTAssertEqualObjects(createResponse.getExtraMsg, @"LAUNCH_OK", @"createCallPeformance, EXTRAMSG NOT MATCH IN CREATE_RESPONSE");
    
    return chatId;
}

- (void)closeCallPeformance:(int64_t)chatId from:(MCUser *)from callEventHandlerFrom:(RtsPerformanceHandler *)callEventHandlerFrom callEventHandlerTo:(RtsPerformanceHandler *)callEventHandlerTo {
    [from closeCall:chatId];
    [NSThread sleepForTimeInterval:1.0];
    
    RtsMessageData *byeRequest = [callEventHandlerTo pollBye:1.0];
    XCTAssertNotNil(byeRequest, @"closeCallPeformance, BYE_REQUEST IS NIL");
    XCTAssertTrue(chatId == byeRequest.getChatId, @"closeCallPeformance, CHAT_ID NOT MATCH IN BYE_REQUEST");
    XCTAssertTrue(byeRequest.getExtraMsg.length == 0, @"closeCallPeformance, BYE_REASON NOT MATCH IN BYE_REQUEST");
    
    RtsMessageData *byeResponse = [callEventHandlerFrom pollBye:1.0];
    XCTAssertNotNil(byeResponse, @"closeCallPeformance, BYE_RESPONSE IS NIL");
    XCTAssertTrue(chatId == byeResponse.getChatId, @"closeCallPeformance, CHAT_ID NOT MATCH IN BYE_RESPONSE");
    XCTAssertEqualObjects(byeResponse.getExtraMsg, @"CLOSED_INITIATIVELY", @"closeCallPeformance, BYE_REASON NOT MATCH IN BYE_RESPONSE");
}

- (void)logOut:(MCUser *)user {
    int64_t beforeLogoutTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
    [user logout];
    
    while([[NSDate date] timeIntervalSince1970]*1000 - beforeLogoutTimestamp < 5000 && [user isOnline]) {
        [NSThread sleepForTimeInterval:0.05];
    }
    XCTAssertFalse([user isOnline], @"logOut, LOGOUT FAILED, USER STILL ONLINE");
}

- (NSString *)randomStringWithLength:(int)len {
    NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i = 0; i < len; ++i) {
        [randomString appendFormat: @"%c", [characters characterAtIndex: arc4random_uniform([characters length])]];
    }
    return randomString;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
