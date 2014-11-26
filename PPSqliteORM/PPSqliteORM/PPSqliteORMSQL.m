//
//  PPSqliteORMSQL.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/26.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

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

@end
