//
//  SkilingStorageUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StorageUtil : NSObject

+ (NSDictionary *)getDeviceStorageInfo;

// 设备内存管理相关方法
+ (double)getDeviceTotalMemorySize;
+ (double)getDeviceUsedMemorySize;
+ (NSNumber *)getDeviceTotalStorageSize;
+ (NSNumber *)getDeviceAvailableStorageSize;

// 设备系统运行时间相关方法
+ (NSString *)getDeviceSystemUptime;
+ (NSString *)getDeviceProcessUptime;
+ (NSString *)getDeviceBootTime;

// 辅助方法
+ (NSString *)formatStorageSize:(long long)bytes;

@end

NS_ASSUME_NONNULL_END
