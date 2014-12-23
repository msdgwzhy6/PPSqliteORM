//
//  NSDictionary+SQL.m
//  PPSqliteORM
//
//  Created by StarNet on 12/22/14.
//  Copyright (c) 2014 StarNet. All rights reserved.
//

#import "NSDictionary+SQL.h"
#import "NSObject+PPSqliteORM.h"

@implementation NSDictionary (SQL)
- (NSString* )sqlValue {
    NSData* data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString* str = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
    return [str sqlValue];
}

+ (id)objectForSQL:(NSString* )sql {
    if (!sql) return nil;
    
    return [NSJSONSerialization JSONObjectWithData:[sql dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}
@end
