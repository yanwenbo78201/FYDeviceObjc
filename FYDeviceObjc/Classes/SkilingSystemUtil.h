//
//  SkilingSystemUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SkilingSystemUtil : NSObject
+ (NSString *)getSkilingDeviceSettingDeviceVersion;
+ (NSString *)getSkilingDeviceSettingAppVersion;
+ (NSString *)getSkilingDeviceSettingScreenResolution;
+ (NSString *)getSkilingDeviceSettingNumberOfCPU;
+ (NSNumber *) getSkilingDeviceBatteryLevel;
+ (NSString *)getSkilingDeviceBatteryCharing;
+ (NSString *)getSkilingDeviceDefaultLanguage;
+ (NSString *)getSkilingDeviceDefaultTimeZone;
+ (NSString *)getSkilingDeviceSreenBrightness;
+ (BOOL)getSkilingDeviceIsAttachedDebugger;
+ (NSString *)getSkilingDeviceIsBelongToSimulator;
+ (NSString *)getSkilingDeviceAdvertisingIdentifier;
+ (NSString *)getSkilingDeviceSettingDeviceName;
+ (NSNumber *)getSkilingDeviceSettingNumberDeviceType;
+ (NSString *)getSkilingDeviceSettingStrDeviceType;
+ (NSString *)getSkilingDeviceSettingDeviceType;
+ (NSDictionary *)getSkilingDeviceSettingInfo;
@end

NS_ASSUME_NONNULL_END
