//
//  SubDevice.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "SubDevice.h"
#import "PPSqliteORMProtocol.h"

@interface SubDevice () {

}

@end

@implementation SubDevice

@synthesize device_id;
@synthesize device_name;
@synthesize is_active;
@synthesize is_online;
@synthesize is_bind;

PPSqliteORMAsignPrimaryKey(device_id);
PPSqliteORMAsignRegisterName(@"subdevice");

- (NSString* )description {
    return [NSString stringWithFormat:@"device_id=%@", device_id];
}

@end
