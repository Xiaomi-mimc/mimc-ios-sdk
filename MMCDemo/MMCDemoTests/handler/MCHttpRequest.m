//
//  MCHttpRequest.m
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import "MCHttpRequest.h"

@implementation MCHttpRequest

+ (NSMutableURLRequest *)generateRequest:(NSURL *)url appId:(int64_t)appId appKey:(NSString *)appKey
                               appSecret:(NSString *)appSecret appAccount:(NSString *)appAccount {
    if (url == nil || appId == 0 || appKey.length == 0 || appSecret.length == 0 || appAccount.length ==0) {
        NSLog(@"generateRequest, parameter is nil");
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *dicObj = [[NSMutableDictionary alloc] init];
    [dicObj setObject:[NSNumber numberWithLongLong:appId] forKey:@"appId"];
    [dicObj setObject:appKey forKey:@"appKey"];
    [dicObj setObject:appSecret forKey:@"appSecret"];
    [dicObj setObject:appAccount forKey:@"appAccount"];
    
    NSData *dicData = [NSJSONSerialization dataWithJSONObject:dicObj options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:dicData];
    return request;
}
@end
