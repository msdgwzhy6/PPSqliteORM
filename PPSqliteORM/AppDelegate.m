//
//  AppDelegate.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "AppDelegate.h"
#import "PPSqliteORM.h"
#import "Student.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    PPSqliteORMManager* manager = [PPSqliteORMManager defaultManager];
    [manager registerClass:[Student class] complete:NULL];
    srand((unsigned)time(0));
    
    NSMutableArray* array = [NSMutableArray array];
    
    int num = 10;
    for (int i = 0; i < num; i++) {
        Student* stu = [[Student alloc] init];
        stu.name = [NSString stringWithFormat:@"Student%d", i];
        stu.sex = rand()&0x1?YES:NO;
        stu.age = rand()%100+1;
        stu.code = [NSString stringWithFormat:@"2014%d", i];
        stu.school = @"Fuzhou middle School";
        stu.brithday = [NSDate date];
        [array addObject:stu];
    }
    [manager writeObjects:array complete:^(BOOL successed, id result) {
    }];
    
    [manager count:[Student class] condition:nil complete:^(BOOL successed, id result) {
    }];
    
    //read
    [manager read:[Student class] condition:@"_code = '201410'" complete:^(BOOL successed, id result) {
        Student* stu = [result firstObject];
        NSLog(@"stu=%@", stu);
    }];
    
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
