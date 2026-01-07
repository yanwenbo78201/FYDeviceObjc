//
//  SkilingCommutieUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommutieUtil : NSObject
+ (NSDictionary *)getDeviceCommunicationInfo;

// 设备网络连接相关方法
+ (NSString *)getDeviceNetworkProxyStatus;
+ (NSString *)getDeviceVPNConnectionStatus;
+ (NSString *)getDeviceNetworkType;
+ (NSString *)getDeviceNetworkDetailType;
+ (NSString *)getDeviceMobileNetworkType;
+ (NSDictionary *)getDeviceWiFiNetworkInfo;

// 网络状态检测辅助方法
+ (BOOL)isDeviceNetworkReachable;
+ (BOOL)isDeviceNetworkUsingWiFi;
+ (BOOL)isDeviceNetworkUsingCellular;

@end

NS_ASSUME_NONNULL_END
