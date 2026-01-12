//
//  SkilingStorageUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StorageUtil : NSObject

+ (NSDictionary *)getDeviceStorageInfo NS_SWIFT_NAME(deviceStorageInfo());

// 设备内存管理相关方法
+ (double)getDeviceTotalMemorySize NS_SWIFT_NAME(deviceTotalMemorySize());
+ (double)getDeviceUsedMemorySize NS_SWIFT_NAME(deviceUsedMemorySize());
+ (NSNumber *)getDeviceTotalStorageSize NS_SWIFT_NAME(deviceTotalStorageSize());
+ (NSNumber *)getDeviceAvailableStorageSize NS_SWIFT_NAME(deviceAvailableStorageSize());

// 设备系统运行时间相关方法
+ (NSString *)getDeviceSystemUptime NS_SWIFT_NAME(deviceSystemUptime());
+ (NSString *)getDeviceProcessUptime NS_SWIFT_NAME(deviceProcessUptime());
+ (NSString *)getDeviceBootTime NS_SWIFT_NAME(deviceBootTime());

// 辅助方法
+ (NSString *)formatStorageSize:(long long)bytes NS_SWIFT_NAME(formatStorageSize(_:));

@end

NS_ASSUME_NONNULL_END
