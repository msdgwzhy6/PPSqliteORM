//
//  PPSqliteORMError.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/26.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "PPSqliteORMError.h"

static NSString* PPSqliteORMErrorDomain = @"PPSqliteORMErrorDomain";

@implementation PPSqliteORMError

+ (id)errorWithCode:(NSInteger)code {
    return [PPSqliteORMError errorWithDomain:PPSqliteORMErrorDomain code:code userInfo:nil];
}

@end
