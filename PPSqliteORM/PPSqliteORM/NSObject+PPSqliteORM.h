//
//  NSObject+PPSqliteORM.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPSqliteORMProtocol.h"

@interface NSObject (PPSqliteORM) <PPSqliteORMProtocol>

+ (NSString* )tableName;

/**
 * Return the Dictionary which contains all variable of this object.
 */
+ (NSDictionary* )variableMap;

/**
 * Convert object to string for SQL insert.
 */
- (NSString* )sqlValue;

/**
 * Convert SQL string to object.
 */
+ (id)valueForSQL:(NSString* )sql;

@end
