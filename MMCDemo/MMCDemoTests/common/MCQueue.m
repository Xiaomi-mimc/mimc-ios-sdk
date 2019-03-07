//
//  MCQueue.m
//  Tests
//
//  Created by zhangdan on 2017/12/29.
//  Copyright © 2017年 zhangdan. All rights reserved.
//

#import "MCQueue.h"

@interface MCQueue()
@property(nonatomic) NSMutableArray *array;
@end

@implementation MCQueue

- (id)init {
    if (self = [super init]) {
        self.array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)push:(id)msg {
    @synchronized (self) {
        NSLog(@"before push: _array=%@, _array.count=%d", self.array, (int)self.array.count);
        
        [self.array addObject:msg];
        
        NSLog(@"after push: _array=%@, _array.count=%d", self.array, (int)self.array.count);
    }
}

- (void)addAll:(NSArray *)array {
    @synchronized (self) {
        [self.array addObjectsFromArray:array];
    }
}

- (id)pop:(int64_t)timeout {
    @synchronized (self) {
        if ([self size] == 0) {
            NSLog(@"pop, _array is nil");
            return nil;
        }
        
        NSLog(@"pop, _array=%@, _array.len=%d", self.array, (int)self.array.count);
        id msg = [self.array objectAtIndex:0];
        while (msg == nil) {
            NSLog(@"pop, sleep");
            [NSThread sleepForTimeInterval:timeout];
            msg = [self.array objectAtIndex:0];
        }
        
        [self.array removeObjectAtIndex:0];
        return msg;
    }
}

- (int)size {
    @synchronized (self) {
        return (int)[self.array count];
    }
}

- (void)clear {
    @synchronized (self) {
        [self.array removeAllObjects];
    }
}

- (NSMutableArray *)getArray {
    return self.array;
}
@end
