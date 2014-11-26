//
//  NSNumber+SQL.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/26.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "NSNumber+SQL.h"

@implementation NSNumber (SQL)

- (NSString* )sqlValue {
    return [self stringValue];
}

+ (id)valueForSQL:(NSString* )sql {
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    return [fmt numberFromString:sql];
}

@end
