//
//  Capture.h
//  MMCDemo
//
//  Created by lijia8 on 2018/12/12.
//  Copyright © 2018 com.xiaomi.mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CaptureDelegate <NSObject>
- (void)returnCaptureData:(NSMutableData *)data;
@end

@interface Capture : NSObject
@property (nonatomic,strong) id<CaptureDelegate>delegate;
- (void)startRecord;
- (void)stopRecord;
@end
