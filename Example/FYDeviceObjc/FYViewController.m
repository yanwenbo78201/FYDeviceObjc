//
//  FYViewController.m
//  FYDeviceObjc
//
//  Created by Computer on 01/07/2026.
//  Copyright (c) 2026 Computer. All rights reserved.
//

#import "FYViewController.h"
#import <SkilingStorageUtil.h>
#import <SkilingSystemUtil.h>
#import <SkilingCommutieUtil.h>

@interface FYViewController ()

@end

@implementation FYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableDictionary *shoppingOtherInfo = [NSMutableDictionary dictionary];
    NSDictionary *skilingSystemInfo = [SkilingSystemUtil getSkilingDeviceSettingInfo];
    [shoppingOtherInfo addEntriesFromDictionary:skilingSystemInfo];
    [shoppingOtherInfo addEntriesFromDictionary:[SkilingStorageUtil getSkilingStorageInfo]];
    [shoppingOtherInfo addEntriesFromDictionary:[SkilingCommutieUtil getSkilingComutieInfo]];
    shoppingOtherInfo[@"rooted"] = @"false";
    NSLog(@"%@",shoppingOtherInfo);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
