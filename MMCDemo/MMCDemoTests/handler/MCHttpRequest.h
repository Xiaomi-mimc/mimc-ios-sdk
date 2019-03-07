//
//  MCHttpRequest.h
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCHttpRequest : NSObject

+ (NSMutableURLRequest *)generateRequest:(NSURL *)url appId:(int64_t)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret appAccount:(NSString *)appAccount;
@end
