//
//  SkilingCommutieUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkilingCommutieUtil : NSObject
+ (NSDictionary *)getSkilingComutieInfo;

// 滑雪网络连接相关方法
+ (NSString *)getSkiingNetworkProxyStatus;
+ (NSString *)getSkiingVPNConnectionStatus;
+ (NSString *)getSkiingNetworkType;
+ (NSString *)getSkiingNetworkDetailType;
+ (NSString *)getSkiingMobileNetworkType;
+ (NSDictionary *)getSkiingWiFiNetworkInfo;

// 网络状态检测辅助方法
+ (BOOL)isSkiingNetworkReachable;
+ (BOOL)isSkiingNetworkUsingWiFi;
+ (BOOL)isSkiingNetworkUsingCellular;

@end

NS_ASSUME_NONNULL_END
