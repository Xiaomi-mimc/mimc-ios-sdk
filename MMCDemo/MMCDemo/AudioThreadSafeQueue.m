//
//  AudioThreadSafeQueue.m
//  MMCDemo
//
//  Created by lijia8 on 2019/2/21.
//  Copyright © 2019 mimc. All rights reserved.
//

#import "AudioThreadSafeQueue.h"

@interface AudioThreadSafeQueue()
@property(nonatomic, strong) NSMutableArray *arrays;
@end

@implementation AudioThreadSafeQueue

- (id)init {
    if (self = [super init]) {
        self.arrays = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)pop {
    @synchronized (self) {
        if ([_arrays count] == 0) {
            return nil;
        }
        
        id object = [_arrays objectAtIndex:0];
        if (object == nil) {
            NSLog(@"pop, object is nil");
            return nil;
        }
        
        [_arrays removeObjectAtIndex:0];
        return object;
    }
}

- (void)push:(id)object {
    @synchronized (self) {
        if (object == nil) {
            NSLog(@"push, object is nil");
            return;
        }
        
        [_arrays addObject:object];
    }
}

- (void)clear {
    @synchronized (self) {
        [_arrays removeAllObjects];
    }
}

- (NSUInteger)getQueueCount {
    @synchronized (self) {
        return [_arrays count];
    }
}

@end
