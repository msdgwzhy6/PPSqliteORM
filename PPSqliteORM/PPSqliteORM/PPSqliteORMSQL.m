/**
 * PPSqliteORMSQL.m
 *
 * Provide the sql statement.
 *
 * MIT licence follows:
 *
 * Copyright (C) 2014 Wenva <lvyexuwenfa100@126.com>
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "PPSqliteORMSQL.h"
#import "NSObject+PPSqliteORM.h"

#define kObjectCTypeToSqliteTypeMap \
@{\
    @"c":               @"INTEGER",\
    @"C":               @"INTEGER",\
    @"s":               @"INTEGER",\
    @"S":               @"INTEGER",\
    @"i":               @"INTEGER",\
    @"I":               @"INTEGER",\
    @"q":               @"INTEGER",\
    @"B":               @"INTEGER",\
    @"f":               @"REAL",\
    @"d":               @"REAL",\
    @"NSString":        @"TEXT",\
    @"NSMutableString": @"TEXT",\
    @"NSDate":          @"REAL",\
    @"NSNumber":        @"INTEGER",\
}


@implementation PPSqliteORMSQL

+ (NSString* )sqlForQueryAllTables {
    return [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type = 'table'"];
}

+ (NSString* )sqlForCreateTable:(Class<PPSqliteORMProtocol>)clazz {
    static NSDictionary* typeMap;
    typeMap = kObjectCTypeToSqliteTypeMap;
    
    //Table Name
    NSString* tableName = [clazz tableName];
    NSString* primaryKey = [clazz primary];
    
    
    //Attributes
    NSMutableString* columns = [NSMutableString string];
    BOOL beAssignPrimaryKey = YES;
    NSDictionary* map = [clazz variableMap];
    NSLog(@"atributes=%@", map);
    
    BOOL first = YES;
    for (NSString* key in map) {
        if (!first) [columns appendString:@","];
        first = NO;
        [columns appendFormat:@"%@ %@", key, typeMap[map[key]]];
        if (beAssignPrimaryKey && [primaryKey isEqualToString:key]) {
            [columns appendFormat:@" PRIMARY KEY"];
            beAssignPrimaryKey = NO;
        }
    }
    
    return [NSString stringWithFormat:@"CREATE TABLE %@(%@)", tableName, columns];
}

+ (NSString* )sqlForDropTable:(Class<PPSqliteORMProtocol>)clazz {
    NSString* tableName = [clazz tableName];
    return [NSString stringWithFormat:@"DROP TABLE %@", tableName];
}

+ (NSString* )sqlForInsert:(id<PPSqliteORMProtocol>)object {
    NSString* tableName = [[object class] tableName];
    
    NSMutableString* columns = [NSMutableString string];
    NSMutableString* values = [NSMutableString string];
    
    NSArray* keys = [[[object class] variableMap] allKeys];
    BOOL first = YES;
    for (NSString* key in keys) {
        if (!first) {
            [columns appendString:@","];
            [values appendString:@","];
        }
        first = NO;
        
        [columns appendString:key];
        [values appendString:[[(NSObject*)object valueForKey:key] sqlValue]];
    }

    return [NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)", tableName, columns, values];
}

+ (NSString* )sqlForDelete:(id<PPSqliteORMProtocol>)object {
    NSString* tableName = [[object class] tableName];
    NSString* primaryKey = [[object class] primary];

    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@", tableName, primaryKey, [[(NSObject*)object valueForKey:primaryKey] sqlValue]];
    
}

+ (NSString* )sqlForQuery:(Class<PPSqliteORMProtocol>)clazz where:(NSString* )condition {
    if (!condition || [condition isEqualToString:@""]) {
        return [NSString stringWithFormat:@"SELECT * FROM %@", [clazz tableName]];
    } else {
        return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", [clazz tableName], condition];
    }
}

+ (NSString* )sqlForCount:(Class<PPSqliteORMProtocol>)clazz where:(NSString* )condition {
    if (!condition || [condition isEqualToString:@""]) {
        return [NSString stringWithFormat:@"SELECT count(*) FROM %@", [clazz tableName]];
    } else {
        return [NSString stringWithFormat:@"SELECT count(*) FROM %@ WHERE %@", [clazz tableName], condition];
    }
}

@end
