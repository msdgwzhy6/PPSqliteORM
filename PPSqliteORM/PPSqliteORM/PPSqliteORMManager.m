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
    dispatch_queue_t    _queue;
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
        _queue = dispatch_queue_create("PPSqliteORMQueue", NULL);

        NSString* path = [NSString stringWithFormat:@"%@/Documents/PPSqliteORM.sqlite", NSHomeDirectory()];
        PPSqliteORMDebug(@"SQLITE DB FILE PATH: %@", path);
        _fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}

- (void)dealloc {

}

- (void)executeComplete:(PPSqliteORMComplete)complete successed:(BOOL)successed result:(id)result {
    if (complete) {
        complete(successed, result);
    }
}

//FMDB Don't allow 'inDatabase' nest.
- (void)executeCompleteAsyn:(PPSqliteORMComplete)complete successed:(BOOL)successed result:(id)result {
    if (complete) {
        dispatch_async(_queue, ^{
            complete(successed, result);
        });
    }
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
        [self executeComplete:complete successed:NO result:PPSqliteORMErrorMacro(PPSqliteORMRegisterFailed)];
        return;
    }
    
    NSString* tableName = [clazz tableName];
    if (!tableName || [tableName isEqualToString:@""]) {
        [self executeComplete:complete successed:NO result:PPSqliteORMErrorMacro(PPSqliteORMTableNameEmpty)];
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
        
        [self executeCompleteAsyn:complete successed:successed result:result];
    }];
}
    

- (void)unregisterClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete {
    if (!clazz) {
        [self executeComplete:complete successed:NO result:PPSqliteORMErrorMacro(PPSqliteORMRegisterFailed)];
        return;
    }
    
    NSString* tableName = [clazz tableName];
    if (!tableName || [tableName isEqualToString:@""]) {
        [self executeComplete:complete successed:NO result:PPSqliteORMErrorMacro(PPSqliteORMTableNameEmpty)];
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
        
        [self executeCompleteAsyn:complete successed:successed result:result];
    }];
}

- (void)unregisterAllClass:(PPSqliteORMComplete)complete {
    [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* sql = [PPSqliteORMSQL sqlForQueryAllTables];
        FMResultSet* rs = [db executeQuery:sql];
        BOOL successed = YES;
        id result;
        while ([rs next]) {
            sql = [PPSqliteORMSQL sqlForDropTableName:[rs stringForColumn:@"name"]];
            PPSqliteORMDebug(@"DROP TABLE SQL:%@", sql);

            BOOL success = [db executeUpdate:sql];
            if (!success) {
                result = PPSqliteORMErrorMacro(PPSqliteORMUnregisterFailed);
                *rollback = YES;
                break;
            }
        }
        [rs close];
        [self executeCompleteAsyn:complete successed:successed result:result];
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
        
        [self executeCompleteAsyn:complete successed:successed result:result];
    }];
}

- (void)writeObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete {

    if ([objects count]) {
        [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL successed = YES;
            id result;
            for (NSObject<PPSqliteORMProtocol> * object in objects) {
                successed = [db executeUpdate:[PPSqliteORMSQL sqlForInsert:object]];
                if (!successed) {
                    *rollback = YES;
                    result = PPSqliteORMErrorMacro(PPSqliteORMWriteFailed);
                    break;
                }
            }
            
            [self executeCompleteAsyn:complete successed:successed result:result];
        }];
    } else {
        [self executeComplete:complete successed:YES result:nil];
    }
}

- (void)deleteObject:(id)object complete:(PPSqliteORMComplete)complete {
    NSString* tableName = [[object class] tableName];
    NSString* primaryKey = [[object class] primary];
    
    if (object) {
        //check where assign primary key
        if (!primaryKey) {
            [self executeComplete:complete successed:NO result:PPSqliteORMErrorMacro(PPSqliteORMNotAssignPrimaryKey)];
            return;
        }
        
        //check table
        [_fmdbQueue inDatabase:^(FMDatabase *db) {
            BOOL successed = YES;
            id result;

            if (tableName && [db tableExists:tableName]) {
                NSString* sql = [PPSqliteORMSQL sqlForDelete:object];
                PPSqliteORMDebug(@"DELETE VALUE SQL:%@", sql);
                
                successed = [db executeUpdate:sql];
                if (!successed) {
                    result = PPSqliteORMErrorMacro(PPSqliteORMDeleteFailed);
                }
            } else {
                result = PPSqliteORMErrorMacro(PPSqliteORMUsedWithoutRegister);
            }
            [self executeCompleteAsyn:complete successed:successed result:result];
        }];
    } else {
        if (complete) complete(YES, nil);
    }
}

- (void)deleteObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete {
    if ([objects count]) {
        [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            BOOL successed = YES;
            id result;
            for (NSObject<PPSqliteORMProtocol> * object in objects) {
                successed = [db executeUpdate:[PPSqliteORMSQL sqlForDelete:object]];
                if (!successed) {
                    *rollback = YES;
                    result = PPSqliteORMErrorMacro(PPSqliteORMWriteFailed);
                    return;
                }
            }
            
            [self executeCompleteAsyn:complete successed:successed result:result];
        }];
    } else {
        [self executeComplete:complete successed:YES result:nil];
    }
}

- (void)deleteAllObjects:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete {
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [PPSqliteORMSQL sqlForDeleteAll:clazz];
        PPSqliteORMDebug(@"DELETE ALL SQL:%@", sql);
        BOOL successed = [db executeUpdate:sql];
        id result;
        if (!successed) {
            result = PPSqliteORMErrorMacro(PPSqliteORMDeleteFailed);
        }
        [self executeCompleteAsyn:complete successed:successed result:result];
    }];
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
        [self executeCompleteAsyn:complete successed:YES result:[NSArray arrayWithArray:array]];
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
        [self executeCompleteAsyn:complete successed:YES result:result];
    }];
}

@end
