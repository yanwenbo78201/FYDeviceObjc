//
//  FYFYDeviceObjc.m
//  FYDeviceObjc_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import "FYFYDeviceObjc.h"
#import "SkilingStorageUtil.h"
#import "SkilingSystemUtil.h"
#import "SkilingCommutieUtil.h"
#import <FYDeviceObjc/FYFYDeviceObjc.h>
@implementation FYFYDeviceObjc
- (NSDictionary *)deviceInfo{
    NSMutableDictionary *shoppingOtherInfo = [NSMutableDictionary dictionary];
    NSDictionary *skilingSystemInfo = [SkilingSystemUtil getSkilingDeviceSettingInfo];
    [shoppingOtherInfo addEntriesFromDictionary:skilingSystemInfo];
    [shoppingOtherInfo addEntriesFromDictionary:[SkilingStorageUtil getSkilingStorageInfo]];
    [shoppingOtherInfo addEntriesFromDictionary:[SkilingCommutieUtil getSkilingComutieInfo]];
    shoppingOtherInfo[@"rooted"] = @"false";
    
    [[[FYFYDeviceObjc alloc] init] deviceInfo];
    return shoppingOtherInfo;
}

@end
