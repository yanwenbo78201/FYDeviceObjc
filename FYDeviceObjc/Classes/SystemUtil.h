//
//  SkilingSystemUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SystemUtil : NSObject

+ (NSString *)getDeviceSystemVersion;
+ (NSString *)getDeviceAppVersion;
+ (NSString *)getDeviceScreenResolution;
+ (NSString *)getDeviceCPUCount;
+ (NSNumber *)getDeviceBatteryLevel;
+ (NSString *)getDeviceBatteryChargingStatus;
+ (NSString *)getDeviceDefaultLanguage;
+ (NSString *)getDeviceDefaultTimeZone;
+ (NSString *)getDeviceScreenBrightness;
+ (BOOL)isDeviceAttachedDebugger;
+ (NSString *)isDeviceSimulator;
+ (NSString *)getDeviceAdvertisingIdentifier;
+ (NSString *)getDeviceName;
+ (NSNumber *)getDeviceTypeNumber;
+ (NSString *)getDeviceTypeString;
+ (NSString *)getDeviceType;
+ (NSDictionary *)getDeviceSystemInfo;
@end

NS_ASSUME_NONNULL_END
