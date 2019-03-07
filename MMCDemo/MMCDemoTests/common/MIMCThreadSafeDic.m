//
//  MIMCThreadSafeDic.m
//  MMCSDK
//
//  Created by zhangdan on 2018/7/17.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import "MIMCThreadSafeDic.h"

@interface MIMCThreadSafeDic()
@property(nonatomic) NSMutableDictionary *dictionary;
@end

@implementation MIMCThreadSafeDic

- (id)init {
    if (self = [super init]) {
        self.dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)put:(NSString *)key value:(id)value {
    @synchronized (self) {
        [self.dictionary setObject:value forKey:key];
    }
}

- (void)remove:(NSString *)key {
    @synchronized (self) {
        [self.dictionary removeObjectForKey:key];
    }
}

- (NSMutableDictionary *)getDic {
    @synchronized (self) {
        return self.dictionary;
    }
}

- (int)getCount {
    @synchronized (self) {
        return self.dictionary.count;
    }
}
@end
