//
//  AppDelegate.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "AppDelegate.h"
#include "Device.h"
#import "SubDevice.h"

#import "PPSqliteORMManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    NSLog(@"Dict=%@", [[SubDevice variableMap] allKeys]);
    
    PPSqliteORMManager* manager = [PPSqliteORMManager defaultManager];
    [manager registerClass:[SubDevice class] complete:^(BOOL successed, id result) {
        NSLog(@"successed=%d", successed);
    }];
    
    for (int i = 0; i < 100; i++) {
        SubDevice* dev = [[SubDevice alloc] init];
        dev.device_id = [NSString stringWithFormat:@"%d", i];
        dev.device_name = [NSString stringWithFormat:@"室内机%d", i];
        dev.is_active = NO;
        dev.is_bind = YES;
        dev.is_online = YES;
        [manager writeObject:dev complete:^(BOOL successed, id result) {
//            NSLog(@"write dev%d successed=%d", i, successed);
        }];
        
    }
    
    [manager read:[SubDevice class] condition:nil complete:^(BOOL successed, id result) {
        NSLog(@"read successed=%d, result = %@", successed, result);
    }];
    
    [manager count:[SubDevice class] condition:nil complete:^(BOOL successed, id result) {
        NSLog(@"count successed=%d, result = %@", successed, result);
    }];

//    [manager unregisterClass:[SubDevice class] complete:^(BOOL successed, id result) {
//        NSLog(@"successed=%d", successed);
//    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
