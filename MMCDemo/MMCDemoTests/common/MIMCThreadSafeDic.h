//
//  MIMCThreadSafeDic.h
//  MMCSDK
//
//  Created by zhangdan on 2018/7/17.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIMCThreadSafeDic : NSObject

- (id)init;
- (void)put:(NSString *)key value:(id)value;
- (void)remove:(NSString *)key;
- (NSMutableDictionary *)getDic;
- (int)getCount;
@end
