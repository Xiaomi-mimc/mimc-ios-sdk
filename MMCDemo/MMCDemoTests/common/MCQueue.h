//
//  MCQueue.h
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCQueue : NSObject

- (id)init;
- (void)push:(id)msg;
- (void)addAll:(NSArray *)array;
- (id)pop:(int64_t)timeout;
- (int)size;
- (void)clear;
- (NSMutableArray *)getArray;
@end
