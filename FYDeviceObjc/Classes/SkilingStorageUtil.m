//
//  SkilingStorageUtil.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "SkilingStorageUtil.h"
#import <mach/mach.h>
#include <sys/sysctl.h>

@implementation SkilingStorageUtil

#pragma mark - Public Storage Methods

+ (NSDictionary *)getSkilingStorageInfo
{
    NSMutableDictionary *skilingStorageInfo = [NSMutableDictionary dictionary];
    skilingStorageInfo[@"ramTotal"] = [NSString stringWithFormat:@"%.6f",[SkilingStorageUtil getSkiingEquipmentTotalMemorySize]];
    skilingStorageInfo[@"ramCanUse"] = [NSString stringWithFormat:@"%f",[SkilingStorageUtil getSkiingEquipmentTotalMemorySize] - [SkilingStorageUtil getSkiingEquipmentUsedMemorySize]];
    skilingStorageInfo[@"cashTotal"] = [NSString stringWithFormat:@"%.6f",[[SkilingStorageUtil getSkiingEquipmentTotalStorageSize] floatValue]];
    skilingStorageInfo[@"cashCanUse"] = [NSString stringWithFormat:@"%.6f",[[SkilingStorageUtil getSkiingEquipmentAvailableStorageSize] floatValue]];
    skilingStorageInfo[@"totalBootTime"] = [SkilingStorageUtil getSkiingEquipmentSystemUptime];
    skilingStorageInfo[@"totalBootTimeWake"] = [SkilingStorageUtil getSkiingEquipmentProcessUptime];
    skilingStorageInfo[@"lastBootTime"] = [SkilingStorageUtil getSkiingEquipmentBootTime];
    return  skilingStorageInfo;
}

+ (NSNumber *)getSkiingEquipmentTotalStorageSize {
    long long skiingTotalDiskSpace = [self getSkiingDiskTotalSpace];
    
    if (skiingTotalDiskSpace < 0) {
        return @0;
    }
    
    NSString *skiingFormattedSize = [self formatSkiingStorageSize:skiingTotalDiskSpace];
    if (skiingFormattedSize) {
        double skiingStorageValue = [self extractSkiingNumericValueFromFormattedString:skiingFormattedSize];
        return @(skiingStorageValue);
    }
    
    return @0;
}

+ (NSNumber *)getSkiingEquipmentAvailableStorageSize {
    long long skiingAvailableDiskSpace = [self getSkiingDiskAvailableSpace];
    
    if (skiingAvailableDiskSpace <= 0) {
        return @0;
    }
    
    NSString *skiingFormattedSize = [self formatSkiingStorageSize:skiingAvailableDiskSpace];
    if (skiingFormattedSize) {
        double skiingStorageValue = [self extractSkiingNumericValueFromFormattedString:skiingFormattedSize];
        return @(skiingStorageValue);
    }
    
    return @0;
}

#pragma mark - Public Memory Methods

+ (double)getSkiingEquipmentTotalMemorySize {
    double skiingPhysicalMemory = [self getSkiingPhysicalMemorySize];
    double skiingRoundedMemory = [self roundSkiingMemoryToNearest256MB:skiingPhysicalMemory];
    
    if (skiingRoundedMemory <= 0) {
        return -1;
    }
    
    return skiingRoundedMemory / 1024.0; // 转换为GB
}

+ (double)getSkiingEquipmentUsedMemorySize {
    vm_statistics_data_t skiingVMStats;
    vm_size_t skiingPageSize;
    
    if (![self getSkiingVMStatistics:&skiingVMStats pageSize:&skiingPageSize]) {
        return -1;
    }
    
    natural_t skiingUsedMemoryBytes = [self calculateSkiingUsedMemory:skiingVMStats pageSize:skiingPageSize];
    double skiingUsedMemoryGB = [self convertSkiingBytesToGB:skiingUsedMemoryBytes];
    
    return skiingUsedMemoryGB;
}

#pragma mark - Public Uptime Methods

+ (NSString *)getSkiingEquipmentSystemUptime {
    struct timeval skiingBootTime;
    if (![self getSkiingBootTime:&skiingBootTime]) {
        return @"-1";
    }
    
    struct timeval skiingCurrentTime;
    [self getSkiingCurrentTime:&skiingCurrentTime];
    
    long long skiingUptimeMilliseconds = [self calculateSkiingUptimeInMilliseconds:skiingCurrentTime bootTime:skiingBootTime];
    return [NSString stringWithFormat:@"%lld", skiingUptimeMilliseconds];
}

+ (NSString *)getSkiingEquipmentProcessUptime {
    NSProcessInfo *skiingProcessInfo = [NSProcessInfo processInfo];
    NSTimeInterval skiingUptimeInterval = [skiingProcessInfo systemUptime];
    long long skiingUptimeMilliseconds = (long long)(skiingUptimeInterval * 1000);
    
    return [NSString stringWithFormat:@"%lld", skiingUptimeMilliseconds];
}

+ (NSString *)getSkiingEquipmentBootTime {
    long long skiingSystemUptime = [[self getSkiingEquipmentSystemUptime] longLongValue];
    NSTimeInterval skiingBootTimeInterval = (double)skiingSystemUptime / 1000.0;
    NSDate *skiingBootDate = [NSDate dateWithTimeIntervalSinceNow:(0 - skiingBootTimeInterval)];
    long skiingBootTimestamp = [skiingBootDate timeIntervalSince1970] * 1000;
    
    return [NSString stringWithFormat:@"%ld", skiingBootTimestamp];
}

#pragma mark - Public Utility Methods

+ (NSString *)formatSkiingStorageSize:(long long)bytes {
    if (bytes <= 0) {
        return nil;
    }
    
    double skiingNumberBytes = 1.0 * bytes;
    double skiingTotalGB = skiingNumberBytes / (1024 * 1024 * 1024);
    double skiingTotalMB = skiingNumberBytes / (1024 * 1024);
    
    NSString *skiingFormattedSize = nil;
    
    if (skiingTotalGB >= 1.0) {
        skiingFormattedSize = [NSString stringWithFormat:@"%.2f GB", skiingTotalGB];
    } else if (skiingTotalMB >= 1.0) {
        skiingFormattedSize = [NSString stringWithFormat:@"%.2f MB", skiingTotalMB];
    } else {
        skiingFormattedSize = [self formatSkiingBytesWithCommas:bytes];
    }
    
    return skiingFormattedSize;
}

#pragma mark - Private Storage Helper Methods

+ (long long)getSkiingDiskTotalSpace {
    NSError *skiingError = nil;
    NSDictionary *skiingFileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&skiingError];
    
    if (skiingError != nil) {
        return -1;
    }
    
    long long skiingTotalSpace = [[skiingFileAttributes objectForKey:NSFileSystemSize] longLongValue];
    return skiingTotalSpace > 0 ? skiingTotalSpace : -1;
}

+ (long long)getSkiingDiskAvailableSpace {
    NSError *skiingError = nil;
    NSDictionary *skiingFileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&skiingError];
    
    if (skiingError != nil) {
        return -1;
    }
    
    long long skiingAvailableSpace = [[skiingFileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    return skiingAvailableSpace;
}

+ (double)extractSkiingNumericValueFromFormattedString:(NSString *)formattedString {
    NSArray *skiingComponents = [formattedString componentsSeparatedByString:@" "];
    if (skiingComponents.count > 0) {
        return [[skiingComponents firstObject] doubleValue];
    }
    return 0.0;
}

+ (NSString *)formatSkiingBytesWithCommas:(long long)bytes {
    NSNumberFormatter *skiingFormatter = [[NSNumberFormatter alloc] init];
    [skiingFormatter setPositiveFormat:@"###,###,###,###"];
    NSNumber *skiingBytesNumber = [NSNumber numberWithLongLong:bytes];
    NSString *skiingFormattedBytes = [skiingFormatter stringFromNumber:skiingBytesNumber];
    
    if (skiingFormattedBytes && skiingFormattedBytes.length > 0) {
        return [skiingFormattedBytes stringByAppendingString:@" bytes"];
    }
    
    return nil;
}

#pragma mark - Private Memory Helper Methods

+ (double)getSkiingPhysicalMemorySize {
    double skiingPhysicalMemory = [[NSProcessInfo processInfo] physicalMemory];
    return (skiingPhysicalMemory / 1024.0) / 1024.0; // 转换为MB
}

+ (double)roundSkiingMemoryToNearest256MB:(double)memoryInMB {
    int skiingToNearest = 256;
    int skiingRemainder = (int)memoryInMB % skiingToNearest;
    
    if (skiingRemainder >= skiingToNearest / 2) {
        return ((int)memoryInMB - skiingRemainder) + 256;
    } else {
        return (int)memoryInMB - skiingRemainder;
    }
}

+ (BOOL)getSkiingVMStatistics:(vm_statistics_data_t *)vmStats pageSize:(vm_size_t *)pageSize {
    mach_port_t skiingHostPort = mach_host_self();
    mach_msg_type_number_t skiingHostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    
    if (host_page_size(skiingHostPort, pageSize) != KERN_SUCCESS) {
        return NO;
    }
    
    return host_statistics(skiingHostPort, HOST_VM_INFO, (host_info_t)vmStats, &skiingHostSize) == KERN_SUCCESS;
}

+ (double)calculateSkiingUsedMemory:(vm_statistics_data_t)vmStats pageSize:(vm_size_t)pageSize {
    return (double)((vmStats.active_count + vmStats.inactive_count + vmStats.wire_count) * pageSize);
}

+ (double)convertSkiingBytesToGB:(natural_t)bytes {
    return ((double)bytes / 1024.0) / 1024.0 / 1024.0;
}

#pragma mark - Private Uptime Helper Methods

+ (BOOL)getSkiingBootTime:(struct timeval *)bootTime {
    int skiingMib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t skiingSize = sizeof(*bootTime);
    
    int skiingResult = sysctl(skiingMib, 2, bootTime, &skiingSize, NULL, 0);
    return (skiingResult != -1 && bootTime->tv_sec != 0);
}

+ (void)getSkiingCurrentTime:(struct timeval *)currentTime {
    struct timezone skiingCurrentTimeZone;
    gettimeofday(currentTime, &skiingCurrentTimeZone);
}

+ (long long)calculateSkiingUptimeInMilliseconds:(struct timeval)currentTime bootTime:(struct timeval)bootTime {
    long long skiingUptimeMilliseconds = ((long long)(currentTime.tv_sec - bootTime.tv_sec)) * 1000;
    skiingUptimeMilliseconds += (currentTime.tv_usec - bootTime.tv_usec) / 1000;
    return skiingUptimeMilliseconds;
}

@end
