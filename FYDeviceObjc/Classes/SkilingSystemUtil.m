//
//  SkilingSystemUtil.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "SkilingSystemUtil.h"
#import <sys/utsname.h>
#include <sys/sysctl.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/ASIdentifierManager.h>

@implementation SkilingSystemUtil
+ (NSDictionary *)getSkilingDeviceSettingInfo{
   
    NSMutableDictionary *skilingSystemInfo = [NSMutableDictionary dictionary];
    skilingSystemInfo[@"idfa"] = [SkilingSystemUtil getSkilingDeviceAdvertisingIdentifier];
    skilingSystemInfo[@"idfv"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    skilingSystemInfo[@"phoneMark"] = [[UIDevice currentDevice] name];
    skilingSystemInfo[@"phoneType"] = [SkilingSystemUtil getSkilingDeviceSettingDeviceType];
    skilingSystemInfo[@"systemVersions"] = [SkilingSystemUtil getSkilingDeviceSettingDeviceVersion];
    skilingSystemInfo[@"versionCode"] = [SkilingSystemUtil getSkilingDeviceSettingAppVersion];
    skilingSystemInfo[@"screenResolution"] = [SkilingSystemUtil getSkilingDeviceSettingScreenResolution];
    skilingSystemInfo[@"batteryLevel"] = [SkilingSystemUtil getSkilingDeviceBatteryLevel];
    
    skilingSystemInfo[@"charged"] = [SkilingSystemUtil getSkilingDeviceBatteryCharing];
    skilingSystemInfo[@"defaultLanguage"] = [SkilingSystemUtil getSkilingDeviceDefaultLanguage];
    skilingSystemInfo[@"defaultTimeZone"] = [SkilingSystemUtil getSkilingDeviceDefaultTimeZone];
    skilingSystemInfo[@"screenWidth"] = [NSString stringWithFormat:@"%d",(int)[UIScreen mainScreen].bounds.size.width];
    skilingSystemInfo[@"screenHeight"] = [NSString stringWithFormat:@"%d",(int)[UIScreen mainScreen].bounds.size.height];
    skilingSystemInfo[@"cpuNum"] = [SkilingSystemUtil getSkilingDeviceSettingNumberOfCPU];
    skilingSystemInfo[@"simulated"] = [SkilingSystemUtil getSkilingDeviceIsBelongToSimulator];
    skilingSystemInfo[@"debugged"] = [SkilingSystemUtil getSkilingDeviceIsAttachedDebugger] == YES ? @"true" : @"false";
    skilingSystemInfo[@"screenBrightness"] = [SkilingSystemUtil getSkilingDeviceSreenBrightness];
    return skilingSystemInfo;
}



+ (NSNumber *)getSkilingDeviceSettingNumberDeviceType{
    NSNumber *skilingDeviceNumberDeviceType = @0;
   
    NSString *detailDeviceType = [self getSkilingDeviceSettingDeviceType];
    if ([detailDeviceType hasPrefix:@"iPhone"])
        skilingDeviceNumberDeviceType = @3;
    else if ([detailDeviceType hasPrefix:@"iPad"])
        skilingDeviceNumberDeviceType = @2;
    else if ([detailDeviceType hasPrefix:@"iMac"] || [detailDeviceType hasPrefix:@"Mac"])
        skilingDeviceNumberDeviceType = @1;

    return skilingDeviceNumberDeviceType;
}

+ (NSString *)getSkilingDeviceSettingStrDeviceType{
    NSString *skilingDeviceStringDeviceType = @"unknown";
    NSString *detailDeviceType = [self getSkilingDeviceSettingDeviceType];
    if ([detailDeviceType hasPrefix:@"iPhone"])
        skilingDeviceStringDeviceType = @"Mobile";
    else if ([detailDeviceType hasPrefix:@"iPad"])
        skilingDeviceStringDeviceType = @"Tablet";
    else if ([detailDeviceType hasPrefix:@"iMac"] || [detailDeviceType hasPrefix:@"Mac"])
        skilingDeviceStringDeviceType = @"pc";
    return skilingDeviceStringDeviceType;
}

+ (NSString *)getSkilingDeviceSettingDeviceType{
    NSString *skilingDeviceType = [self getRawDeviceType];
    return [self getDeviceNameFromType:skilingDeviceType];
}

#pragma mark - Private Helper Methods

+ (NSString *)calculateScreenResolution{
    CGFloat skilingScreenScale = [UIScreen mainScreen].scale;
    CGRect skilingScreenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenResolutionWidth = skilingScreenBounds.size.width * skilingScreenScale;
    CGFloat screenResolutionHeight = skilingScreenBounds.size.height * skilingScreenScale;
    return [NSString stringWithFormat:@"%d-%d",(int)screenResolutionWidth,(int)screenResolutionHeight];
}

+ (BOOL)checkDebuggerAttachment{
    @try {
        int attachedRet;
        int attachedMibs[4];
        struct kinfo_proc info;
        size_t size;
        info.kp_proc.p_flag = 0;
        attachedMibs[0] = CTL_KERN;
        attachedMibs[1] = KERN_PROC;
        attachedMibs[2] = KERN_PROC_PID;
        attachedMibs[3] = getpid();
        size = sizeof(info);
        attachedRet = sysctl(attachedMibs, sizeof(attachedMibs) / sizeof(*attachedMibs), &info, &size, NULL, 0);
        if (attachedRet) {
            return attachedRet;
        }
        return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
    }
    @catch (NSException *exception) {
        return NO;
    }
}

+ (NSString *)getAdvertisingIdentifier{
    __block NSString *advertisingIdentifier = @"";
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            }
        }];
    } else {
        advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    }
    return advertisingIdentifier;
}

+ (NSString *)getRawDeviceType{
    struct utsname dtname;
    uname(&dtname);
    return [NSString stringWithFormat:@"%s", dtname.machine];
}

+ (NSString *)getDeviceNameFromType:(NSString *)deviceType{
    // Simulator devices
    if ([self isSimulatorDevice:deviceType]) {
        return [self getSimulatorDeviceName:deviceType];
    }
    
    // iPhone devices
    if ([self isiPhoneDevice:deviceType]) {
        return [self getiPhoneDeviceName:deviceType];
    }
    
    // iPad devices  
    if ([self isiPadDevice:deviceType]) {
        return [self getiPadDeviceName:deviceType];
    }
    
    // iPod devices
    if ([self isiPodDevice:deviceType]) {
        return [self getiPodDeviceName:deviceType];
    }
    
    // Apple TV devices
    if ([self isAppleTVDevice:deviceType]) {
        return [self getAppleTVDeviceName:deviceType];
    }
    
    // Default fallback
    return deviceType;
}

+ (BOOL)isSimulatorDevice:(NSString *)deviceType {
    return [deviceType isEqualToString:@"i386"] || [deviceType isEqualToString:@"x86_64"] || [deviceType isEqualToString:@"arm64"];
}

+ (BOOL)isiPhoneDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"iPhone"];
}

+ (BOOL)isiPadDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"iPad"];
}

+ (BOOL)isiPodDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"iPod"];
}

+ (BOOL)isAppleTVDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"AppleTV"];
}

+ (NSString *)getSimulatorDeviceName:(NSString *)deviceType {
    return @"iPhone Simulator";
}

+ (NSString *)getiPhoneDeviceName:(NSString *)deviceType {
    NSDictionary *iPhoneModels = [self getiPhoneModelDictionary];
    NSString *modelName = iPhoneModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSString *)getiPadDeviceName:(NSString *)deviceType {
    NSDictionary *iPadModels = [self getiPadModelDictionary];
    NSString *modelName = iPadModels[deviceType];
    if (modelName) {
        return modelName;
    }
    return [deviceType hasPrefix:@"iPad"] ? @"iPad" : deviceType;
}

+ (NSString *)getiPodDeviceName:(NSString *)deviceType {
    NSDictionary *iPodModels = [self getiPodModelDictionary];
    NSString *modelName = iPodModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSString *)getAppleTVDeviceName:(NSString *)deviceType {
    NSDictionary *appleTVModels = [self getAppleTVModelDictionary];
    NSString *modelName = appleTVModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSDictionary *)getiPhoneModelDictionary {
    return @{
        @"iPhone1,1": @"iPhone",
        @"iPhone1,2": @"iPhone 3G",
        @"iPhone2,1": @"iPhone 3GS",
        @"iPhone3,1": @"iPhone 4",
        @"iPhone4,1": @"iPhone 4S",
        @"iPhone5,1": @"iPhone 5",
        @"iPhone5,2": @"iPhone 5",
        @"iPhone5,3": @"iPhone 5c",
        @"iPhone5,4": @"iPhone 5c",
        @"iPhone6,1": @"iPhone 5s",
        @"iPhone6,2": @"iPhone 5s",
        @"iPhone7,1": @"iPhone 6 Plus",
        @"iPhone7,2": @"iPhone 6",
        @"iPhone8,1": @"iPhone 6s",
        @"iPhone8,2": @"iPhone 6s Plus",
        @"iPhone8,4": @"iPhone SE",
        @"iPhone9,1": @"iPhone 7",
        @"iPhone9,3": @"iPhone 7",
        @"iPhone9,2": @"iPhone 7 Plus",
        @"iPhone9,4": @"iPhone 7 Plus",
        @"iPhone10,1": @"iPhone 8",
        @"iPhone10,4": @"iPhone 8",
        @"iPhone10,2": @"iPhone 8 Plus",
        @"iPhone10,5": @"iPhone 8 Plus",
        @"iPhone10,3": @"iPhone X",
        @"iPhone10,6": @"iPhone X",
        @"iPhone11,8": @"iPhone XR",
        @"iPhone11,2": @"iPhone XS",
        @"iPhone11,6": @"iPhone XS Max",
        @"iPhone12,1": @"iPhone 11",
        @"iPhone12,3": @"iPhone 11 Pro",
        @"iPhone12,5": @"iPhone 11 Pro Max",
        @"iPhone12,8": @"iPhone SE 2",
        @"iPhone13,1": @"iPhone 12 mini",
        @"iPhone13,2": @"iPhone 12",
        @"iPhone13,3": @"iPhone 12 Pro",
        @"iPhone13,4": @"iPhone 12 Pro Max",
        @"iPhone14,4": @"iPhone 13 mini",
        @"iPhone14,5": @"iPhone 13",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPhone14,6": @"iPhone SE 3",
        @"iPhone14,7": @"iPhone 14",
        @"iPhone14,8": @"iPhone 14 Plus",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,3": @"iPhone 14 Pro Max",
        @"iPhone15,4": @"iPhone 15",
        @"iPhone15,5": @"iPhone 15 Plus",
        @"iPhone16,1": @"iPhone 15 Pro",
        @"iPhone16,2": @"iPhone 15 Pro Max",
        @"iPhone17,3": @"iPhone 16",
        @"iPhone17,4": @"iPhone 16 Plus",
        @"iPhone17,1": @"iPhone 16 Pro",
        @"iPhone17,2": @"iPhone 16 Pro Max",
        @"iPhone18,1": @"iPhone 17 Pro",
        @"iPhone18,2": @"iPhone 17 Pro Max",
        @"iPhone18,3": @"iPhone 17",
        @"iPhone18,4": @"iPhone Air"
    };
}

+ (NSDictionary *)getiPadModelDictionary {
    return @{
        @"iPad1,1": @"iPad",
        @"iPad2,1": @"iPad 2", @"iPad2,2": @"iPad 2", @"iPad2,3": @"iPad 2", @"iPad2,4": @"iPad 2",
        @"iPad2,5": @"iPad mini", @"iPad2,6": @"iPad mini", @"iPad2,7": @"iPad mini",
        @"iPad3,1": @"iPad 3", @"iPad3,2": @"iPad 3", @"iPad3,3": @"iPad 3",
        @"iPad3,4": @"iPad 4", @"iPad3,5": @"iPad 4", @"iPad3,6": @"iPad 4",
        @"iPad4,1": @"iPad Air", @"iPad4,2": @"iPad Air", @"iPad4,3": @"iPad Air",
        @"iPad4,4": @"iPad mini 2", @"iPad4,5": @"iPad mini 2", @"iPad4,6": @"iPad mini 2",
        @"iPad4,7": @"iPad mini 3", @"iPad4,8": @"iPad mini 3", @"iPad4,9": @"iPad mini 3",
        @"iPad5,1": @"iPad mini 4", @"iPad5,2": @"iPad mini 4",
        @"iPad5,3": @"iPad Air 2", @"iPad5,4": @"iPad Air 2",
        @"iPad6,3": @"iPad Pro (9.7-inch)", @"iPad6,4": @"iPad Pro (9.7-inch)",
        @"iPad6,7": @"iPad Pro (12.9-inch)", @"iPad6,8": @"iPad Pro (12.9-inch)",
        @"iPad6,11": @"iPad 5", @"iPad6,12": @"iPad 5",
        @"iPad7,1": @"iPad Pro 2 (12.9-inch)", @"iPad7,2": @"iPad Pro 2 (12.9-inch)",
        @"iPad7,3": @"iPad Pro (10.5-inch)", @"iPad7,4": @"iPad Pro (10.5-inch)",
        @"iPad7,5": @"iPad 6", @"iPad7,6": @"iPad 6",
        @"iPad7,11": @"iPad 7", @"iPad7,12": @"iPad 7",
        @"iPad8,1": @"iPad Pro (11-inch)", @"iPad8,2": @"iPad Pro (11-inch)",
        @"iPad8,3": @"iPad Pro (11-inch)", @"iPad8,4": @"iPad Pro (11-inch)",
        @"iPad8,5": @"iPad Pro 3 (12.9-inch)", @"iPad8,6": @"iPad Pro 3 (12.9-inch)",
        @"iPad8,7": @"iPad Pro 3 (12.9-inch)", @"iPad8,8": @"iPad Pro 3 (12.9-inch)",
        @"iPad8,9": @"iPad Pro 2 (11-inch)", @"iPad8,10": @"iPad Pro 2 (11-inch)",
        @"iPad8,11": @"iPad Pro 4 (12.9-inch)", @"iPad8,12": @"iPad Pro 4 (12.9-inch)",
        @"iPad11,1": @"iPad mini 5", @"iPad11,2": @"iPad mini 5",
        @"iPad11,3": @"iPad Air 3", @"iPad11,4": @"iPad Air 3",
        @"iPad11,6": @"iPad 8", @"iPad11,7": @"iPad 8",
        @"iPad12,1": @"iPad 9", @"iPad12,2": @"iPad 9",
        @"iPad13,1": @"iPad Air 4", @"iPad13,2": @"iPad Air 4",
        @"iPad13,4": @"iPad Pro 3 (11-inch)", @"iPad13,5": @"iPad Pro 3 (11-inch)",
        @"iPad13,6": @"iPad Pro 3 (11-inch)", @"iPad13,7": @"iPad Pro 3 (11-inch)",
        @"iPad13,8": @"iPad Pro 5 (12.9-inch)", @"iPad13,9": @"iPad Pro 5 (12.9-inch)",
        @"iPad13,10": @"iPad Pro 5 (12.9-inch)", @"iPad13,11": @"iPad Pro 5 (12.9-inch)",
        @"iPad13,16": @"iPad Air 5", @"iPad13,17": @"iPad Air 5",
        @"iPad14,1": @"iPad mini 6", @"iPad14,2": @"iPad mini 6"
    };
}

+ (NSDictionary *)getiPodModelDictionary {
    return @{
        @"iPod1,1": @"iPod Touch 1G",
        @"iPod2,1": @"iPod Touch 2G",
        @"iPod3,1": @"iPod Touch 3G",
        @"iPod4,1": @"iPod Touch 4G",
        @"iPod5,1": @"iPod Touch 5G",
        @"iPod7,1": @"iPod Touch 6G",
        @"iPod9,1": @"iPod Touch 7G"
    };
}

+ (NSDictionary *)getAppleTVModelDictionary {
    return @{
        @"AppleTV2,1": @"Apple TV 2",
        @"AppleTV3,1": @"Apple TV 3",
        @"AppleTV3,2": @"Apple TV 3 (2013)"
    };
}

+ (NSString *)getSkilingDeviceSettingDeviceVersion{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(systemVersion)]) {
        NSString *skilingDeviceVersion = [[UIDevice currentDevice] systemVersion];
        return skilingDeviceVersion;
    } else {
        return @"";
    }
}

+ (NSString *)getSkilingDeviceSettingAppVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)getSkilingDeviceSettingScreenResolution{
    return [self calculateScreenResolution];
}

+ (NSString *)getSkilingDeviceSettingNumberOfCPU{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(processorCount)]) {
        NSInteger skilingNumberOfCPU = [[NSProcessInfo processInfo] processorCount];
        return [NSString stringWithFormat:@"%ld",(long)skilingNumberOfCPU];
    } else {
        return @"-1";
    }
}



+ (NSNumber *)getSkilingDeviceBatteryLevel{
    UIDevice *skilingDevice = [UIDevice currentDevice];
    skilingDevice.batteryMonitoringEnabled = YES;
    float skilingBatteryLevel = 0.0;
    float skilingBatteryCharge = [skilingDevice batteryLevel];
    if (skilingBatteryCharge > 0.0f) {
        skilingBatteryLevel = skilingBatteryCharge * 100;
        return @(skilingBatteryLevel);
    } else {
        // Unable to find the battery level
        return @(-1);
    }
}

+ (NSString *)getSkilingDeviceBatteryCharing{
    UIDevice *skilingDevice = [UIDevice currentDevice];
    skilingDevice.batteryMonitoringEnabled = YES;
    if ([skilingDevice batteryState] == UIDeviceBatteryStateCharging || [skilingDevice batteryState] == UIDeviceBatteryStateFull) {
        return @"true";
    } else {
        return @"false";
    }
}
+ (NSString *)getSkilingDeviceDefaultLanguage{
    NSArray *skilingLanguages = [NSLocale preferredLanguages];
    // Get the user's language
    NSString *skilingLanguage = [skilingLanguages objectAtIndex:0];
    if (skilingLanguage == nil || skilingLanguage.length <= 0) {
        return @"null";
    }
    return [skilingLanguage componentsSeparatedByString:@"-"].firstObject;
}

+ (NSString *)getSkilingDeviceDefaultTimeZone{
    NSTimeZone *skilingTimeZone = [NSTimeZone systemTimeZone];
    NSString *skilingTimeZoneName = [skilingTimeZone name];
    // Check for validity
    if (skilingTimeZoneName == nil || skilingTimeZoneName.length <= 0) {
        return @"null";
    }
    return skilingTimeZoneName;
}

+ (NSString *)getSkilingDeviceSreenBrightness{
    float skilingBrightness = [UIScreen mainScreen].brightness;
    if (skilingBrightness < 0.0 || skilingBrightness > 1.0) {
        return @"-1";
    }
    return [NSString stringWithFormat:@"%d",(int)(skilingBrightness*100)];
}

+ (BOOL)getSkilingDeviceIsAttachedDebugger{
    return [self checkDebuggerAttachment];
}

+ (NSString *)getSkilingDeviceIsBelongToSimulator{
    NSString *skilingDeviceType = [self getSkilingDeviceSettingDeviceType];
    if ([skilingDeviceType containsString:@"Simulator"]) {
        return @"true";
    }else{
        return @"false";
    }
}

+ (NSString *)getSkilingDeviceAdvertisingIdentifier{
    return [self getAdvertisingIdentifier];
}

+ (NSString *)getSkilingDeviceSettingDeviceName{
    UIDevice *skilingDevice = [UIDevice currentDevice];
    return skilingDevice.name;
}

@end
