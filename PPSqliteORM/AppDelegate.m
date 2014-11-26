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
    
    SubDevice* dev = [[SubDevice alloc] init];
    dev.device_id =@"100";
    dev.device_name = @"室内机110";
    dev.is_active = YES;
    dev.is_bind = YES;
    dev.is_online = NO;

    SubDevice* dev1 = [[SubDevice alloc] init];
    dev1.device_id =@"110";
    dev1.device_name = @"室内机120";
    dev1.is_active = YES;
    dev1.is_bind = YES;
    dev1.is_online = NO;

    
    [manager writeObject:dev complete:^(BOOL successed, id result) {
        NSLog(@"write dev successed=%d", successed);
    }];
    
    [manager writeObject:dev1 complete:^(BOOL successed, id result) {
        NSLog(@"write dev1 successed=%d", successed);;
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
