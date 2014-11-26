//
//  NSString+SQL.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/26.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "NSString+SQL.h"

@implementation NSString (SQL)
- (NSString* )sqlValue {
    return [NSString stringWithFormat:@"\"%@\"", self];
}

+ (id)valueForSQL:(NSString* )sql {
    return sql;
}

@end
