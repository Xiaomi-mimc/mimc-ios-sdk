//
//  Player.h
//  MMCDemo
//
//  Created by lijia8 on 2018/12/12.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Player : NSObject

// 播放
- (void)playWithData:(NSData *)data;

@end
