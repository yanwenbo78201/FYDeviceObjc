//
//  SkilingSystemUtil.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SystemUtil : NSObject

+ (NSString *)getDeviceSystemVersion NS_SWIFT_NAME(deviceSystemVersion());
+ (NSString *)getDeviceAppVersion NS_SWIFT_NAME(deviceAppVersion());
+ (NSString *)getDeviceScreenResolution NS_SWIFT_NAME(deviceScreenResolution());
+ (NSString *)getDeviceCPUCount NS_SWIFT_NAME(deviceCPUCount());
+ (NSNumber *)getDeviceBatteryLevel NS_SWIFT_NAME(deviceBatteryLevel());
+ (NSString *)getDeviceBatteryChargingStatus NS_SWIFT_NAME(deviceBatteryChargingStatus());
+ (NSString *)getDeviceDefaultLanguage NS_SWIFT_NAME(deviceDefaultLanguage());
+ (NSString *)getDeviceDefaultTimeZone NS_SWIFT_NAME(deviceDefaultTimeZone());
+ (NSString *)getDeviceScreenBrightness NS_SWIFT_NAME(deviceScreenBrightness());
+ (BOOL)isDeviceAttachedDebugger NS_SWIFT_NAME(isAttachedDebugger());
+ (NSString *)isDeviceSimulator NS_SWIFT_NAME(isSimulator());
+ (NSString *)getDeviceAdvertisingIdentifier NS_SWIFT_NAME(deviceAdvertisingIdentifier());
+ (NSString *)getDeviceName NS_SWIFT_NAME(deviceName());
+ (NSNumber *)getDeviceTypeNumber NS_SWIFT_NAME(deviceTypeNumber());
+ (NSString *)getDeviceTypeString NS_SWIFT_NAME(deviceTypeString());
+ (NSString *)getDeviceType NS_SWIFT_NAME(deviceType());
+ (NSDictionary *)getDeviceSystemInfo NS_SWIFT_NAME(deviceSystemInfo());
@end

NS_ASSUME_NONNULL_END
