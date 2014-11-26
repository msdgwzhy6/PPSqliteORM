//
//  SubDevice.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "Device.h"

@interface SubDevice : Device {
    NSString* device_id;
    NSString* device_name;
    BOOL is_bind;
    BOOL is_active;
    BOOL is_online;
}

@property(nonatomic, strong) NSString* device_id;
@property(nonatomic, strong) NSString* device_name;
@property(nonatomic, assign) BOOL is_bind;
@property(nonatomic, assign) BOOL is_active;
@property(nonatomic, assign) BOOL is_online;

@end
