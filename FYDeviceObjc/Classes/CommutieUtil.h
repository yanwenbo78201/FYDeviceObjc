//
//  SkilingCommutieUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommutieUtil : NSObject
+ (NSDictionary *)getDeviceCommunicationInfo NS_SWIFT_NAME(deviceCommunicationInfo());

// 设备网络连接相关方法
+ (NSString *)getDeviceNetworkProxyStatus NS_SWIFT_NAME(deviceNetworkProxyStatus());
+ (NSString *)getDeviceVPNConnectionStatus NS_SWIFT_NAME(deviceVPNConnectionStatus());
+ (NSString *)getDeviceNetworkType NS_SWIFT_NAME(deviceNetworkType());
+ (NSString *)getDeviceNetworkDetailType NS_SWIFT_NAME(deviceNetworkDetailType());
+ (NSString *)getDeviceMobileNetworkType NS_SWIFT_NAME(deviceMobileNetworkType());
+ (NSDictionary *)getDeviceWiFiNetworkInfo NS_SWIFT_NAME(deviceWiFiNetworkInfo());

// 网络状态检测辅助方法
+ (BOOL)isDeviceNetworkReachable NS_SWIFT_NAME(isNetworkReachable());
+ (BOOL)isDeviceNetworkUsingWiFi NS_SWIFT_NAME(isNetworkUsingWiFi());
+ (BOOL)isDeviceNetworkUsingCellular NS_SWIFT_NAME(isNetworkUsingCellular());

@end

NS_ASSUME_NONNULL_END
