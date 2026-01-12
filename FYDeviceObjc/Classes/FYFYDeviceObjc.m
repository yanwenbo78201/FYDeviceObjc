//
//  FYFYDeviceObjc.m
//  FYDeviceObjc_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import "FYFYDeviceObjc.h"
#import "StorageUtil.h"
#import "CommutieUtil.h"
#import "SystemUtil.h"
#import <FYDeviceObjc/FYFYDeviceObjc.h>

@implementation FYFYDeviceObjc

- (NSDictionary *)deviceInfo {
    NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionary];
    NSDictionary *systemInfo = [SystemUtil getDeviceSystemInfo];
    [deviceInfoDict addEntriesFromDictionary:systemInfo];
    [deviceInfoDict addEntriesFromDictionary:[StorageUtil getDeviceStorageInfo]];
    [deviceInfoDict addEntriesFromDictionary:[CommutieUtil getDeviceCommunicationInfo]];
    deviceInfoDict[@"rooted"] = @"false";
    
    return deviceInfoDict;
}

@end
