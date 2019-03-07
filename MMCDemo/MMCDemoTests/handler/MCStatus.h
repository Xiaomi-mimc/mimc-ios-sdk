//
//  MCStatus.h
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCUser.h"

@interface MCStatus : NSObject<onlineStatusDelegate>

- (void)statusChange:(MCUser *)user status:(int)status errType:(NSString *)errType errReason:(NSString *)errReason errDescription:(NSString *)errDescription;
@end
