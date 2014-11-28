/**
 * PPSqliteORMManager.m
 *
 * Provide the interfaces for user to operate database.
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

#import "PPSqliteORMManager.h"
#import <FMDB.h>
#import <objc/runtime.h>
#import "NSObject+PPSqliteORM.h"
#import "PPSqliteORMError.h"
#import "PPSqliteORMSQL.h"

#if !__has_feature(objc_arc)
#error PPSqliteORM must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

@interface PPSqliteORMManager () {
    FMDatabaseQueue*    _fmdbQueue;
}

@end

@implementation PPSqliteORMManager

+ (id)defaultManager {
    static PPSqliteORMManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PPSqliteORMManager alloc] init];
    });
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        NSString* path = [NSString stringWithFormat:@"%@/Documents/PPSqliteORM.sqlite", NSHomeDirectory()];
        _fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}

- (void)dealloc {

}

- (NSDictionary* )columnInfo:(NSString* )tablename database:(FMDatabase* )db {
    NSString* sql = [PPSqliteORMSQL sqlForTableInfo:tablename];
    FMResultSet* rs = [db executeQuery:sql];
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    
    while ([rs next]) {
        info[[rs stringForColumn:@"name"]] = [rs stringForColumn:@"type"];
    }
    [rs close];
    return [NSDictionary dictionaryWithDictionary:info];
}

- (void)registerClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete {
    if (!clazz) {
        if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMRegisterFailed));
        return;
    }
    
    NSString* tableName = [clazz tableName];
    if (!tableName || [tableName isEqualToString:@""]) {
        if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMTableNameEmpty));
        return;
    }
    
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        BOOL successed = YES;
        id result = nil;
        
        if (![db tableExists:tableName]) {
            NSString* sql = [PPSqliteORMSQL sqlForCreateTable:clazz];
            PPSqliteORMDebug(@"CREATE TABLE SQL:%@", sql);
            successed = [db executeUpdate:sql];
            if (!successed) {
                result = PPSqliteORMErrorMacro(PPSqliteORMRegisterFailed);
            }
        } else {//alter
            NSDictionary* tableInfo = [self columnInfo:[clazz tableName] database:db];
            NSArray* sqls = [PPSqliteORMSQL sqlForAlter:clazz columnInfo:tableInfo];
            for (NSString* sql in sqls) {
                PPSqliteORMDebug(@"ALTER TABLE SQL:%@", sql);
                successed = [db executeUpdate:sql];
                if (!successed) {
                    result = PPSqliteORMErrorMacro(PPSqliteORMRegisterFailed);
                    break;
                }
            }
        }
        
        if (complete) complete(successed, result);
    }];
}
    

- (void)unregisterClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete {
    if (!clazz) {
        if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMRegisterFailed));
        return;
    }
    
    NSString* tableName = [clazz tableName];
    if (!tableName || [tableName isEqualToString:@""]) {
        if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMTableNameEmpty));
        return;
    }
    
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        BOOL successed = YES;
        id result = nil;
        
        if ([db tableExists:tableName]) {
            NSString* sql = [PPSqliteORMSQL sqlForDropTable:clazz];
            PPSqliteORMDebug(@"DROP TABLE SQL:%@", sql);
            successed = [db executeUpdate:sql];
            if (successed) {
                result = PPSqliteORMErrorMacro(PPSqliteORMUnregisterFailed);
            }
        }
        if (complete) complete(successed, result);
    }];
}


- (void)writeObject:(id)object complete:(PPSqliteORMComplete)complete {
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        BOOL successed = YES;
        id result = nil;
        if ([db tableExists:[[object class] tableName]]) {
            NSString* sql = [PPSqliteORMSQL sqlForInsert:object];
            PPSqliteORMDebug(@"INSERT VALUE SQL:%@", sql);

            successed = [db executeUpdate:sql];
            if (!successed) {
                result = PPSqliteORMErrorMacro(PPSqliteORMWriteFailed);
            }
        } else {
            successed = NO;
            result = PPSqliteORMErrorMacro(PPSqliteORMUsedWithoutRegister);
        }
        
        if (complete) complete(successed, result);
    }];
}

- (void)writeObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete {

    if ([objects count]) {
        [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL successed = YES;
            for (NSObject<PPSqliteORMProtocol> * object in objects) {
                successed = [db executeUpdate:[PPSqliteORMSQL sqlForInsert:object]];
                if (!successed) {
                    *rollback = YES;
                    if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMWriteFailed));
                    return;
                }
            }
            
            if (complete) complete(YES, nil);
        }];
    } else {
        if (complete) complete(YES, nil);
    }
}

- (void)deleteObject:(id)object complete:(PPSqliteORMComplete)complete {
    NSString* tableName = [[object class] tableName];
    NSString* primaryKey = [[object class] primary];
    
    //check where assign primary key
    if (!primaryKey) {
        if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMNotAssignPrimaryKey));
        return;
    }
    
    //check table
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        if (tableName && [db tableExists:tableName]) {
            NSString* sql = [PPSqliteORMSQL sqlForDelete:object];
            PPSqliteORMDebug(@"DELETE VALUE SQL:%@", sql);

            BOOL successed = [db executeUpdate:sql];
            id result;
            if (!successed) {
                result = PPSqliteORMErrorMacro(PPSqliteORMDeleteFailed);
            }
            
            if (complete) complete(successed, result);
        } else {
            if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMUsedWithoutRegister));
        }
    }];
    
    
}

- (void)deleteObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete {
    if ([objects count]) {
        [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL successed = YES;
            for (NSObject<PPSqliteORMProtocol> * object in objects) {
                successed = [db executeUpdate:[PPSqliteORMSQL sqlForDelete:object]];
                if (!successed) {
                    *rollback = YES;
                    if (complete) complete(NO, PPSqliteORMErrorMacro(PPSqliteORMWriteFailed));
                    return;
                }
            }
            
            if (complete) complete(YES, nil);
        }];
    } else {
        if (complete) complete(YES, nil);
    }
}

- (void)read:(Class <PPSqliteORMProtocol>)clazz condition:(NSString* )condition complete:(PPSqliteORMComplete)complete {
    NSAssert(clazz, @"Register class can't be Nil");

    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [PPSqliteORMSQL sqlForQuery:clazz where:condition];
        PPSqliteORMDebug(@"SELECT SQL:%@", sql);

        FMResultSet* rs = [db executeQuery:sql];
        NSMutableArray* array = [NSMutableArray array];
        NSArray* columns = [[rs columnNameToIndexMap] allKeys];
        NSDictionary* variables = [clazz variableMap];
        NSDictionary* typeMap = kObjectCTypeToSqliteTypeMap;
        
        while ([rs next]) {
            id obj = [[clazz alloc] init];
            for (NSString* key in columns) {
                NSString* className = typeMap[variables[key]][0];
                Class cls = NSClassFromString(className);
                if (cls) {
                    [obj setValue:[cls objectForSQL:[rs stringForColumn:key]] forKey:key];
                }
            }
            [array addObject:obj];
        }
        
        [rs close];
        if (complete) complete(YES, [NSArray arrayWithArray:array]);
    }];
}

- (void)count:(Class <PPSqliteORMProtocol>)clazz condition:(NSString* )condition complete:(PPSqliteORMComplete)complete {
    NSAssert(clazz, @"Register class can't be Nil");

    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [PPSqliteORMSQL sqlForCount:clazz where:condition];
        PPSqliteORMDebug(@"COUNT SQL:%@", sql);

        FMResultSet* rs = [db executeQuery:sql];
        NSNumber* result;
        if ([rs next]) {
            result = @([rs intForColumnIndex:0]);
        }
        [rs close];
        if (complete) complete(YES, result);
    }];
}

@end
