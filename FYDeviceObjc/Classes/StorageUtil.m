//
//  StorageUtil.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "StorageUtil.h"
#import <mach/mach.h>
#include <sys/sysctl.h>

@implementation StorageUtil

#pragma mark - Public Storage Methods

+ (NSDictionary *)getDeviceStorageInfo
{
    NSMutableDictionary *storageInfo = [NSMutableDictionary dictionary];
    storageInfo[@"ramTotal"] = [NSString stringWithFormat:@"%.6f",[StorageUtil getDeviceTotalMemorySize]];
    storageInfo[@"ramCanUse"] = [NSString stringWithFormat:@"%f",[StorageUtil getDeviceTotalMemorySize] - [StorageUtil getDeviceUsedMemorySize]];
    storageInfo[@"cashTotal"] = [NSString stringWithFormat:@"%.6f",[[StorageUtil getDeviceTotalStorageSize] floatValue]];
    storageInfo[@"cashCanUse"] = [NSString stringWithFormat:@"%.6f",[[StorageUtil getDeviceAvailableStorageSize] floatValue]];
    storageInfo[@"totalBootTime"] = [StorageUtil getDeviceSystemUptime];
    storageInfo[@"totalBootTimeWake"] = [StorageUtil getDeviceProcessUptime];
    storageInfo[@"lastBootTime"] = [StorageUtil getDeviceBootTime];
    return  storageInfo;
}

+ (NSNumber *)getDeviceTotalStorageSize {
    long long totalDiskSpace = [self getDiskTotalSpace];
    
    if (totalDiskSpace < 0) {
        return @0;
    }
    
    NSString *formattedSize = [self formatStorageSize:totalDiskSpace];
    if (formattedSize) {
        double storageValue = [self extractNumericValueFromFormattedString:formattedSize];
        return @(storageValue);
    }
    
    return @0;
}

+ (NSNumber *)getDeviceAvailableStorageSize {
    long long availableDiskSpace = [self getDiskAvailableSpace];
    
    if (availableDiskSpace <= 0) {
        return @0;
    }
    
    NSString *formattedSize = [self formatStorageSize:availableDiskSpace];
    if (formattedSize) {
        double storageValue = [self extractNumericValueFromFormattedString:formattedSize];
        return @(storageValue);
    }
    
    return @0;
}

#pragma mark - Public Memory Methods

+ (double)getDeviceTotalMemorySize {
    double physicalMemory = [self getPhysicalMemorySize];
    double roundedMemory = [self roundMemoryToNearest256MB:physicalMemory];
    
    if (roundedMemory <= 0) {
        return -1;
    }
    
    return roundedMemory / 1024.0; // 转换为GB
}

+ (double)getDeviceUsedMemorySize {
    vm_statistics_data_t vmStats;
    vm_size_t pageSize;
    
    if (![self getVMStatistics:&vmStats pageSize:&pageSize]) {
        return -1;
    }
    
    natural_t usedMemoryBytes = [self calculateUsedMemory:vmStats pageSize:pageSize];
    double usedMemoryGB = [self convertBytesToGB:usedMemoryBytes];
    
    return usedMemoryGB;
}

#pragma mark - Public Uptime Methods

+ (NSString *)getDeviceSystemUptime {
    struct timeval bootTime;
    if (![self getBootTime:&bootTime]) {
        return @"-1";
    }
    
    struct timeval currentTime;
    [self getCurrentTime:&currentTime];
    
    long long uptimeMilliseconds = [self calculateUptimeInMilliseconds:currentTime bootTime:bootTime];
    return [NSString stringWithFormat:@"%lld", uptimeMilliseconds];
}

+ (NSString *)getDeviceProcessUptime {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSTimeInterval uptimeInterval = [processInfo systemUptime];
    long long uptimeMilliseconds = (long long)(uptimeInterval * 1000);
    
    return [NSString stringWithFormat:@"%lld", uptimeMilliseconds];
}

+ (NSString *)getDeviceBootTime {
    long long systemUptime = [[self getDeviceSystemUptime] longLongValue];
    NSTimeInterval bootTimeInterval = (double)systemUptime / 1000.0;
    NSDate *bootDate = [NSDate dateWithTimeIntervalSinceNow:(0 - bootTimeInterval)];
    long bootTimestamp = [bootDate timeIntervalSince1970] * 1000;
    
    return [NSString stringWithFormat:@"%ld", bootTimestamp];
}

#pragma mark - Public Utility Methods

+ (NSString *)formatStorageSize:(long long)bytes {
    if (bytes <= 0) {
        return nil;
    }
    
    double numberBytes = 1.0 * bytes;
    double totalGB = numberBytes / (1024 * 1024 * 1024);
    double totalMB = numberBytes / (1024 * 1024);
    
    NSString *formattedSize = nil;
    
    if (totalGB >= 1.0) {
        formattedSize = [NSString stringWithFormat:@"%.2f GB", totalGB];
    } else if (totalMB >= 1.0) {
        formattedSize = [NSString stringWithFormat:@"%.2f MB", totalMB];
    } else {
        formattedSize = [self formatBytesWithCommas:bytes];
    }
    
    return formattedSize;
}

#pragma mark - Private Storage Helper Methods

+ (long long)getDiskTotalSpace {
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    
    if (error != nil) {
        return -1;
    }
    
    long long totalSpace = [[fileAttributes objectForKey:NSFileSystemSize] longLongValue];
    return totalSpace > 0 ? totalSpace : -1;
}

+ (long long)getDiskAvailableSpace {
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    
    if (error != nil) {
        return -1;
    }
    
    long long availableSpace = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    return availableSpace;
}

+ (double)extractNumericValueFromFormattedString:(NSString *)formattedString {
    NSArray *components = [formattedString componentsSeparatedByString:@" "];
    if (components.count > 0) {
        return [[components firstObject] doubleValue];
    }
    return 0.0;
}

+ (NSString *)formatBytesWithCommas:(long long)bytes {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"###,###,###,###"];
    NSNumber *bytesNumber = [NSNumber numberWithLongLong:bytes];
    NSString *formattedBytes = [formatter stringFromNumber:bytesNumber];
    
    if (formattedBytes && formattedBytes.length > 0) {
        return [formattedBytes stringByAppendingString:@" bytes"];
    }
    
    return nil;
}

#pragma mark - Private Memory Helper Methods

+ (double)getPhysicalMemorySize {
    double physicalMemory = [[NSProcessInfo processInfo] physicalMemory];
    return (physicalMemory / 1024.0) / 1024.0; // 转换为MB
}

+ (double)roundMemoryToNearest256MB:(double)memoryInMB {
    int toNearest = 256;
    int remainder = (int)memoryInMB % toNearest;
    
    if (remainder >= toNearest / 2) {
        return ((int)memoryInMB - remainder) + 256;
    } else {
        return (int)memoryInMB - remainder;
    }
}

+ (BOOL)getVMStatistics:(vm_statistics_data_t *)vmStats pageSize:(vm_size_t *)pageSize {
    mach_port_t hostPort = mach_host_self();
    mach_msg_type_number_t hostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    
    if (host_page_size(hostPort, pageSize) != KERN_SUCCESS) {
        return NO;
    }
    
    return host_statistics(hostPort, HOST_VM_INFO, (host_info_t)vmStats, &hostSize) == KERN_SUCCESS;
}

+ (double)calculateUsedMemory:(vm_statistics_data_t)vmStats pageSize:(vm_size_t)pageSize {
    return (double)((vmStats.active_count + vmStats.inactive_count + vmStats.wire_count) * pageSize);
}

+ (double)convertBytesToGB:(natural_t)bytes {
    return ((double)bytes / 1024.0) / 1024.0 / 1024.0;
}

#pragma mark - Private Uptime Helper Methods

+ (BOOL)getBootTime:(struct timeval *)bootTime {
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(*bootTime);
    
    int result = sysctl(mib, 2, bootTime, &size, NULL, 0);
    return (result != -1 && bootTime->tv_sec != 0);
}

+ (void)getCurrentTime:(struct timeval *)currentTime {
    struct timezone currentTimeZone;
    gettimeofday(currentTime, &currentTimeZone);
}

+ (long long)calculateUptimeInMilliseconds:(struct timeval)currentTime bootTime:(struct timeval)bootTime {
    long long uptimeMilliseconds = ((long long)(currentTime.tv_sec - bootTime.tv_sec)) * 1000;
    uptimeMilliseconds += (currentTime.tv_usec - bootTime.tv_usec) / 1000;
    return uptimeMilliseconds;
}

@end
