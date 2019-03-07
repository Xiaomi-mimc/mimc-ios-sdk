//
//  MCToken.m
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import "MCToken.h"

@implementation MCToken

- (NSString *)parseProxyServiceToken:(NSData *)proxyResult {
    NSLog(@"parseProxyServiceToken, comes");
    NSString *jsonString = [[NSString alloc] initWithData:proxyResult encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end
