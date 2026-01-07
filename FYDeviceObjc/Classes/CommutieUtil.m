//
//  CommutieUtil.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "CommutieUtil.h"
#include <ifaddrs.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation CommutieUtil

#pragma mark - Public Methods

+ (NSDictionary *)getDeviceCommunicationInfo{
    NSMutableDictionary *communicationInfo = [NSMutableDictionary dictionary];
    communicationInfo[@"network"] = [CommutieUtil getDeviceNetworkType];
    NSDictionary *wifiData = [CommutieUtil getDeviceWiFiNetworkInfo];
    NSString *wifiSSID = [wifiData.allKeys containsObject:@"ssid"] ? wifiData[@"ssid"] : @"null";
    NSString *wifiBSSID = [wifiData.allKeys containsObject:@"bssid"] ? wifiData[@"bssid"] : @"null";
    [communicationInfo setValue:wifiSSID forKey:@"wifiName"];
    [communicationInfo setValue:wifiBSSID forKey:@"wifiBssid"];
    
    communicationInfo[@"isvpn"] = [CommutieUtil getDeviceVPNConnectionStatus];
    communicationInfo[@"proxied"] = [CommutieUtil getDeviceNetworkProxyStatus];
    return communicationInfo;
}

+ (NSString *)getDeviceNetworkProxyStatus {
    NSDictionary *proxySettings = [self getSystemProxySettings];
    NSArray *proxies = [self getProxiesForURL:@"http://www.baidu.com" withSettings:proxySettings];
    
    if (proxies.count > 0) {
        NSDictionary *systemSettings = [proxies objectAtIndex:0];
        if ([[systemSettings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]) {
            return @"false";
        } else {
            return @"true";
        }
    }
    return @"false";
}

+ (NSString *)getDeviceVPNConnectionStatus {
    BOOL isVPNConnected = NO;
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    
    if (systemVersion.doubleValue >= 9.0) {
        isVPNConnected = [self checkVPNConnectionModern];
    } else {
        isVPNConnected = [self checkVPNConnectionLegacy];
    }
    
    return isVPNConnected ? @"true" : @"false";
}

+ (NSString *)getDeviceNetworkType {
    NSString *networkDetailType = [self getDeviceNetworkDetailType];
    return [self convertNetworkDetailTypeToCode:networkDetailType];
}

+ (NSString *)getDeviceNetworkDetailType {
    SCNetworkReachabilityFlags flags = [self getNetworkReachabilityFlags];
    
    if (![self isNetworkReachableWithFlags:flags]) {
        return @"notReachable";
    }
    
    if ([self isNetworkRequiresConnectionWithFlags:flags]) {
        return @"notReachable";
    }
    
    if ([self isNetworkUsingWWANWithFlags:flags]) {
        return [self getDeviceMobileNetworkType];
    } else {
        return @"WiFi";
    }
}

+ (NSString *)getDeviceMobileNetworkType {
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *radioAccessTechnology = [self getCurrentRadioAccessTechnology:telephonyInfo];
    
    if (!radioAccessTechnology) {
        return @"notReachable";
    }
    
    return [self classifyMobileNetworkType:radioAccessTechnology];
}

+ (NSDictionary *)getDeviceWiFiNetworkInfo {
    NSArray *supportedInterfaces = [self getSupportedNetworkInterfaces];
    NSDictionary *currentNetworkInfo = [self getCurrentNetworkInfo:supportedInterfaces];
    
    if (currentNetworkInfo) {
        return [self extractWiFiInfoFromNetworkInfo:currentNetworkInfo];
    }
    
    return nil;
}

+ (BOOL)isDeviceNetworkReachable {
    SCNetworkReachabilityFlags flags = [self getNetworkReachabilityFlags];
    return [self isNetworkReachableWithFlags:flags];
}

+ (BOOL)isDeviceNetworkUsingWiFi {
    NSString *networkType = [self getDeviceNetworkDetailType];
    return [networkType isEqualToString:@"WiFi"];
}

+ (BOOL)isDeviceNetworkUsingCellular {
    NSString *networkType = [self getDeviceNetworkDetailType];
    return ![networkType isEqualToString:@"WiFi"] && ![networkType isEqualToString:@"notReachable"];
}

#pragma mark - Private Helper Methods

+ (NSDictionary *)getSystemProxySettings {
    return (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
}

+ (NSArray *)getProxiesForURL:(NSString *)urlString withSettings:(NSDictionary *)settings {
    NSURL *url = [NSURL URLWithString:urlString];
    return (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef)(url), (__bridge CFDictionaryRef)(settings)));
}

+ (BOOL)checkVPNConnectionModern {
    NSDictionary *proxyDict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *systemProxyKeys = [proxyDict[@"__SCOPED__"] allKeys];
    
    for (NSString *key in systemProxyKeys) {
        if ([self isVPNRelatedInterface:key]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkVPNConnectionLegacy {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *tempAddr = NULL;
    int success = getifaddrs(&interfaces);
    
    if (success == 0) {
        tempAddr = interfaces;
        while (tempAddr != NULL) {
            NSString *interfaceName = [NSString stringWithFormat:@"%s", tempAddr->ifa_name];
            if ([self isVPNRelatedInterface:interfaceName]) {
                freeifaddrs(interfaces);
                return YES;
            }
            tempAddr = tempAddr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return NO;
}

+ (BOOL)isVPNRelatedInterface:(NSString *)interfaceName {
    return ([interfaceName rangeOfString:@"tap"].location != NSNotFound ||
            [interfaceName rangeOfString:@"tun"].location != NSNotFound ||
            [interfaceName rangeOfString:@"ipsec"].location != NSNotFound ||
            [interfaceName rangeOfString:@"ppp"].location != NSNotFound);
}

+ (NSString *)convertNetworkDetailTypeToCode:(NSString *)detailType {
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

+ (SCNetworkReachabilityFlags)getNetworkReachabilityFlags {
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL reachabilityFlag = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!reachabilityFlag) {
        return 0;
    }
    
    return flags;
}

+ (BOOL)isNetworkReachableWithFlags:(SCNetworkReachabilityFlags)flags {
    BOOL networkReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return networkReachable && !needsConnection;
}

+ (BOOL)isNetworkRequiresConnectionWithFlags:(SCNetworkReachabilityFlags)flags {
    return (flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired;
}

+ (BOOL)isNetworkUsingWWANWithFlags:(SCNetworkReachabilityFlags)flags {
    return (flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN;
}

+ (NSString *)getCurrentRadioAccessTechnology:(CTTelephonyNetworkInfo *)telephonyInfo {
    if (@available(iOS 12.1, *)) {
        if (telephonyInfo && [telephonyInfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
            NSDictionary *radioDict = [telephonyInfo serviceCurrentRadioAccessTechnology];
            if (radioDict.allKeys.count) {
                return [radioDict objectForKey:radioDict.allKeys[0]];
            }
        }
    } else {
        return telephonyInfo.currentRadioAccessTechnology;
    }
    return nil;
}

+ (NSString *)classifyMobileNetworkType:(NSString *)radioAccessTechnology {
    if (@available(iOS 14.1, *)) {
        if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyNRNSA] ||
            [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyNR]) {
            return @"5G";
        }
    }
    
    if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"4G";
    }
    
    if ([self is3GNetworkType:radioAccessTechnology]) {
        return @"3G";
    }
    
    if ([self is2GNetworkType:radioAccessTechnology]) {
        return @"2G";
    }
    
    return @"Unknow";
}

+ (BOOL)is3GNetworkType:(NSString *)radioAccessTechnology {
    NSArray *network3GTypes = @[
        CTRadioAccessTechnologyWCDMA,
        CTRadioAccessTechnologyHSDPA,
        CTRadioAccessTechnologyHSUPA,
        CTRadioAccessTechnologyCDMAEVDORev0,
        CTRadioAccessTechnologyCDMAEVDORevA,
        CTRadioAccessTechnologyCDMAEVDORevB,
        CTRadioAccessTechnologyeHRPD
    ];
    return [network3GTypes containsObject:radioAccessTechnology];
}

+ (BOOL)is2GNetworkType:(NSString *)radioAccessTechnology {
    NSArray *network2GTypes = @[
        CTRadioAccessTechnologyEdge,
        CTRadioAccessTechnologyGPRS,
        CTRadioAccessTechnologyCDMA1x
    ];
    return [network2GTypes containsObject:radioAccessTechnology];
}

+ (NSArray *)getSupportedNetworkInterfaces {
    return CFBridgingRelease(CNCopySupportedInterfaces());
}

+ (NSDictionary *)getCurrentNetworkInfo:(NSArray *)supportedInterfaces {
    for (NSString *interfaceName in supportedInterfaces) {
        NSDictionary *networkInfo = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((CFStringRef)interfaceName);
        if (networkInfo) {
            return networkInfo;
        }
    }
    return nil;
}

+ (NSMutableDictionary *)extractWiFiInfoFromNetworkInfo:(NSDictionary *)networkInfo {
    NSMutableDictionary *wifiInfo = [NSMutableDictionary dictionary];
    
    if ([networkInfo.allKeys containsObject:@"SSID"]) {
        [wifiInfo setValue:[networkInfo objectForKey:@"SSID"] forKey:@"ssid"];
    }
    
    if ([networkInfo.allKeys containsObject:@"BSSID"]) {
        [wifiInfo setValue:[networkInfo objectForKey:@"BSSID"] forKey:@"bssid"];
    }
    
    return wifiInfo;
}

@end
