//
//  MCStatus.m
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import "MCStatus.h"

@implementation MCStatus

- (void)statusChange:(MCUser *)user status:(int)status errType:(NSString *)errType errReason:(NSString *)errReason errDescription:(NSString *)errDescription {
    NSLog(@"MIMCOnlineStatus, Called, uuid=%@, user=%@, status=%d, errType=%@, errReason=%@, errDescription=%@",user.getUuid, user, status, errType, errReason, errDescription);
}
@end
