//
//  AudioThreadSafeQueue.h
//  MMCDemo
//
//  Created by lijia8 on 2019/2/21.
//  Copyright © 2019 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioThreadSafeQueue : NSMutableArray

- (id)init;
- (void)push:(id)object;
- (id)pop;
- (void)clear;
- (NSUInteger)getQueueCount;

@end

NS_ASSUME_NONNULL_END
