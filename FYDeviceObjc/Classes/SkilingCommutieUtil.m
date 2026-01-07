//
//  SkilingCommutieUtil.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "SkilingCommutieUtil.h"
#include <ifaddrs.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation SkilingCommutieUtil

#pragma mark - Public Methods

+ (NSDictionary *)getSkilingComutieInfo{
    NSMutableDictionary *skilingComutieInfo = [NSMutableDictionary dictionary];
    skilingComutieInfo[@"network"] = [SkilingCommutieUtil getSkiingNetworkType];
    NSDictionary *shoppingWifiData = [SkilingCommutieUtil getSkiingWiFiNetworkInfo];
    NSString *wifiSSID = [shoppingWifiData.allKeys containsObject:@"ssid"] ? shoppingWifiData[@"ssid"] : @"null";
    NSString *wifiBSSID = [shoppingWifiData.allKeys containsObject:@"bssid"] ? shoppingWifiData[@"bssid"] : @"null";
    [skilingComutieInfo setValue:wifiSSID forKey:@"wifiName"];
    [skilingComutieInfo setValue:wifiBSSID forKey:@"wifiBssid"];
    
    skilingComutieInfo[@"isvpn"] = [SkilingCommutieUtil getSkiingVPNConnectionStatus];
    skilingComutieInfo[@"proxied"] = [SkilingCommutieUtil getSkiingNetworkProxyStatus];
    return skilingComutieInfo;
}

+ (NSString *)getSkiingNetworkProxyStatus {
    NSDictionary *skiingProxySettings = [self getSkiingSystemProxySettings];
    NSArray *skiingProxies = [self getSkiingProxiesForURL:@"http://www.baidu.com" withSettings:skiingProxySettings];
    
    if (skiingProxies.count > 0) {
        NSDictionary *skiingSystemSettings = [skiingProxies objectAtIndex:0];
        if ([[skiingSystemSettings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
            return @"false";
        } else {
            return @"true";
        }
    }
    return @"false";
}

+ (NSString *)getSkiingVPNConnectionStatus {
    BOOL skiingIsVPNConnected = NO;
    NSString *skiingSystemVersion = [UIDevice currentDevice].systemVersion;
    
    if (skiingSystemVersion.doubleValue >= 9.0) {
        skiingIsVPNConnected = [self checkSkiingVPNConnectionModern];
    } else {
        skiingIsVPNConnected = [self checkSkiingVPNConnectionLegacy];
    }
    
    return skiingIsVPNConnected ? @"true" : @"false";
}

+ (NSString *)getSkiingNetworkType {
    NSString *skiingNetworkDetailType = [self getSkiingNetworkDetailType];
    return [self convertSkiingNetworkDetailTypeToCode:skiingNetworkDetailType];
}

+ (NSString *)getSkiingNetworkDetailType {
    SCNetworkReachabilityFlags skiingFlags = [self getSkiingNetworkReachabilityFlags];
    
    if (![self isSkiingNetworkReachableWithFlags:skiingFlags]) {
        return @"notReachable";
    }
    
    if ([self isSkiingNetworkRequiresConnectionWithFlags:skiingFlags]) {
        return @"notReachable";
    }
    
    if ([self isSkiingNetworkUsingWWANWithFlags:skiingFlags]) {
        return [self getSkiingMobileNetworkType];
    } else {
        return @"WiFi";
    }
}

+ (NSString *)getSkiingMobileNetworkType {
    CTTelephonyNetworkInfo *skiingTelephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *skiingRadioAccessTechnology = [self getSkiingCurrentRadioAccessTechnology:skiingTelephonyInfo];
    
    if (!skiingRadioAccessTechnology) {
        return @"notReachable";
    }
    
    return [self classifySkiingMobileNetworkType:skiingRadioAccessTechnology];
}

+ (NSDictionary *)getSkiingWiFiNetworkInfo {
    NSArray *skiingSupportedInterfaces = [self getSkiingSupportedNetworkInterfaces];
    NSDictionary *skiingCurrentNetworkInfo = [self getSkiingCurrentNetworkInfo:skiingSupportedInterfaces];
    
    if (skiingCurrentNetworkInfo) {
        return [self extractSkiingWiFiInfoFromNetworkInfo:skiingCurrentNetworkInfo];
    }
    
    return nil;
}

+ (BOOL)isSkiingNetworkReachable {
    SCNetworkReachabilityFlags skiingFlags = [self getSkiingNetworkReachabilityFlags];
    return [self isSkiingNetworkReachableWithFlags:skiingFlags];
}

+ (BOOL)isSkiingNetworkUsingWiFi {
    NSString *skiingNetworkType = [self getSkiingNetworkDetailType];
    return [skiingNetworkType isEqualToString:@"WiFi"];
}

+ (BOOL)isSkiingNetworkUsingCellular {
    NSString *skiingNetworkType = [self getSkiingNetworkDetailType];
    return ![skiingNetworkType isEqualToString:@"WiFi"] && ![skiingNetworkType isEqualToString:@"notReachable"];
}

#pragma mark - Private Helper Methods

+ (NSDictionary *)getSkiingSystemProxySettings {
    return (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
}

+ (NSArray *)getSkiingProxiesForURL:(NSString *)urlString withSettings:(NSDictionary *)settings {
    NSURL *skiingURL = [NSURL URLWithString:urlString];
    return (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef)(skiingURL), (__bridge CFDictionaryRef)(settings)));
}

+ (BOOL)checkSkiingVPNConnectionModern {
    NSDictionary *skiingProxyDict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *skiingSystemProxyKeys = [skiingProxyDict[@"__SCOPED__"] allKeys];
    
    for (NSString *skiingKey in skiingSystemProxyKeys) {
        if ([self isSkiingVPNRelatedInterface:skiingKey]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkSkiingVPNConnectionLegacy {
    struct ifaddrs *skiingInterfaces = NULL;
    struct ifaddrs *skiingTempAddr = NULL;
    int skiingSuccess = getifaddrs(&skiingInterfaces);
    
    if (skiingSuccess == 0) {
        skiingTempAddr = skiingInterfaces;
        while (skiingTempAddr != NULL) {
            NSString *skiingInterfaceName = [NSString stringWithFormat:@"%s", skiingTempAddr->ifa_name];
            if ([self isSkiingVPNRelatedInterface:skiingInterfaceName]) {
                freeifaddrs(skiingInterfaces);
                return YES;
            }
            skiingTempAddr = skiingTempAddr->ifa_next;
        }
    }
    
    freeifaddrs(skiingInterfaces);
    return NO;
}

+ (BOOL)isSkiingVPNRelatedInterface:(NSString *)interfaceName {
    return ([interfaceName rangeOfString:@"tap"].location != NSNotFound ||
            [interfaceName rangeOfString:@"tun"].location != NSNotFound ||
            [interfaceName rangeOfString:@"ipsec"].location != NSNotFound ||
            [interfaceName rangeOfString:@"ppp"].location != NSNotFound);
}

+ (NSString *)convertSkiingNetworkDetailTypeToCode:(NSString *)detailType {
    if ([detailType isEqualToString:@"Unknow"]) {
        return @"0";
    } else if ([detailType isEqualToString:@"WiFi"]) {
        return @"1";
    } else if ([detailType isEqualToString:@"2G"]) {
        return @"2";
    } else if ([detailType isEqualToString:@"3G"]) {
        return @"3";
    } else if ([detailType isEqualToString:@"4G"]) {
        return @"4";
    } else if ([detailType isEqualToString:@"5G"]) {
        return @"5";
    }
    return @"0";
}

+ (SCNetworkReachabilityFlags)getSkiingNetworkReachabilityFlags {
    struct sockaddr_storage skiingZeroAddress;
    bzero(&skiingZeroAddress, sizeof(skiingZeroAddress));
    skiingZeroAddress.ss_len = sizeof(skiingZeroAddress);
    skiingZeroAddress.ss_family = AF_INET;
    
    SCNetworkReachabilityRef skiingReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&skiingZeroAddress);
    SCNetworkReachabilityFlags skiingFlags;
    
    BOOL skiingReachabilityFlag = SCNetworkReachabilityGetFlags(skiingReachability, &skiingFlags);
    CFRelease(skiingReachability);
    
    if (!skiingReachabilityFlag) {
        return 0;
    }
    
    return skiingFlags;
}

+ (BOOL)isSkiingNetworkReachableWithFlags:(SCNetworkReachabilityFlags)flags {
    BOOL skiingNetworkReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL skiingNeedsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return skiingNetworkReachable && !skiingNeedsConnection;
}

+ (BOOL)isSkiingNetworkRequiresConnectionWithFlags:(SCNetworkReachabilityFlags)flags {
    return (flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired;
}

+ (BOOL)isSkiingNetworkUsingWWANWithFlags:(SCNetworkReachabilityFlags)flags {
    return (flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN;
}

+ (NSString *)getSkiingCurrentRadioAccessTechnology:(CTTelephonyNetworkInfo *)telephonyInfo {
    if (@available(iOS 12.1, *)) {
        if (telephonyInfo && [telephonyInfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
            NSDictionary *skiingRadioDict = [telephonyInfo serviceCurrentRadioAccessTechnology];
            if (skiingRadioDict.allKeys.count) {
                return [skiingRadioDict objectForKey:skiingRadioDict.allKeys[0]];
            }
        }
    } else {
        return telephonyInfo.currentRadioAccessTechnology;
    }
    return nil;
}

+ (NSString *)classifySkiingMobileNetworkType:(NSString *)radioAccessTechnology {
    if (@available(iOS 14.1, *)) {
        if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyNRNSA] ||
            [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyNR]) {
            return @"5G";
        }
    }
    
    if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"4G";
    }
    
    if ([self isSkiing3GNetworkType:radioAccessTechnology]) {
        return @"3G";
    }
    
    if ([self isSkiing2GNetworkType:radioAccessTechnology]) {
        return @"2G";
    }
    
    return @"Unknow";
}

+ (BOOL)isSkiing3GNetworkType:(NSString *)radioAccessTechnology {
    NSArray *skiing3GTypes = @[
        CTRadioAccessTechnologyWCDMA,
        CTRadioAccessTechnologyHSDPA,
        CTRadioAccessTechnologyHSUPA,
        CTRadioAccessTechnologyCDMAEVDORev0,
        CTRadioAccessTechnologyCDMAEVDORevA,
        CTRadioAccessTechnologyCDMAEVDORevB,
        CTRadioAccessTechnologyeHRPD
    ];
    return [skiing3GTypes containsObject:radioAccessTechnology];
}

+ (BOOL)isSkiing2GNetworkType:(NSString *)radioAccessTechnology {
    NSArray *skiing2GTypes = @[
        CTRadioAccessTechnologyEdge,
        CTRadioAccessTechnologyGPRS,
        CTRadioAccessTechnologyCDMA1x
    ];
    return [skiing2GTypes containsObject:radioAccessTechnology];
}

+ (NSArray *)getSkiingSupportedNetworkInterfaces {
    return CFBridgingRelease(CNCopySupportedInterfaces());
}

+ (NSDictionary *)getSkiingCurrentNetworkInfo:(NSArray *)supportedInterfaces {
    for (NSString *skiingInterfaceName in supportedInterfaces) {
        NSDictionary *skiingNetworkInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((CFStringRef)skiingInterfaceName);
        if (skiingNetworkInfo) {
            return skiingNetworkInfo;
        }
    }
    return nil;
}

+ (NSMutableDictionary *)extractSkiingWiFiInfoFromNetworkInfo:(NSDictionary *)networkInfo {
    NSMutableDictionary *skiingWifiInfo = [NSMutableDictionary dictionary];
    
    if ([networkInfo.allKeys containsObject:@"SSID"]) {
        [skiingWifiInfo setValue:[networkInfo objectForKey:@"SSID"] forKey:@"ssid"];
    }
    
    if ([networkInfo.allKeys containsObject:@"BSSID"]) {
        [skiingWifiInfo setValue:[networkInfo objectForKey:@"BSSID"] forKey:@"bssid"];
    }
    
    return skiingWifiInfo;
}

@end
