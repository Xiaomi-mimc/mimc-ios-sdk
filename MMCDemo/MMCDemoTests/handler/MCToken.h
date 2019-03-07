//
//  MCToken.h
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCUser.h"

@interface MCToken : NSObject<parseTokenDelegate>

- (NSString *)parseProxyServiceToken:(NSData *)proxyResult;
@end
