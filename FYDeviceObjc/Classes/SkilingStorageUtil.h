//
//  SkilingStorageUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkilingStorageUtil : NSObject

+ (NSDictionary *)getSkilingStorageInfo;

// 滑雪设备内存管理相关方法
+ (double)getSkiingEquipmentTotalMemorySize;
+ (double)getSkiingEquipmentUsedMemorySize;
+ (NSNumber *)getSkiingEquipmentTotalStorageSize;
+ (NSNumber *)getSkiingEquipmentAvailableStorageSize;

// 滑雪设备系统运行时间相关方法
+ (NSString *)getSkiingEquipmentSystemUptime;
+ (NSString *)getSkiingEquipmentProcessUptime;
+ (NSString *)getSkiingEquipmentBootTime;

// 辅助方法
+ (NSString *)formatSkiingStorageSize:(long long)bytes;

@end

NS_ASSUME_NONNULL_END
