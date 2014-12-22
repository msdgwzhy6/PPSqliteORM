//
//  NSDictionary+SQL.m
//  PPSqliteORM
//
//  Created by StarNet on 12/22/14.
//  Copyright (c) 2014 StarNet. All rights reserved.
//

#import "NSDictionary+SQL.h"

@implementation NSDictionary (SQL)
- (NSString* )sqlValue {
    NSData* data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
}

+ (id)objectForSQL:(NSString* )sql {
    return [NSJSONSerialization JSONObjectWithData:[sql dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}
@end
