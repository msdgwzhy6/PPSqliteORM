//
//  PPSqliteORMManager.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "PPSqliteORMManager.h"
#import <FMDB.h>
#import <objc/runtime.h>
#import "NSObject+PPSqliteORM.h"
#import "PPSqliteORMError.h"
#import "PPSqliteORMSQL.h"


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

- (void)registerClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete {
    NSAssert(clazz, @"Register class can't be Nil");
    
    NSString* sql = [PPSqliteORMSQL sqlForCreateTable:clazz];
    NSLog(@"createsql=%@", sql);

    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        BOOL successed = YES;
        id result = nil;
        
        if (![db tableExists:[clazz tableName]]) {
            successed = [db executeUpdate:sql];
            if (!successed) {
                result = [PPSqliteORMError errorWithCode:PPSqliteORMRegisterFailed];
            }
        }
        
        if (complete) complete(successed, result);
    }];
}

- (void)unregisterClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete {
    NSAssert(clazz, @"Register class can't be Nil");
    
    NSString* sql = [PPSqliteORMSQL sqlForDropTable:clazz];
    
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        BOOL successed = YES;
        id result = nil;
        
        if ([db tableExists:[clazz tableName]]) {
            successed = [db executeUpdate:sql];
            if (successed) {
                result = [PPSqliteORMError errorWithCode:PPSqliteORMUnregisterFailed];
            }
        }
        
        if (complete) complete(successed, result);
    }];

}


- (void)writeObject:(id)object complete:(PPSqliteORMComplete)complete {
    
    NSString* sql = [PPSqliteORMSQL sqlForInsert:object];
    [_fmdbQueue inDatabase:^(FMDatabase *db) {
        BOOL successed = YES;
        id result = nil;
        if ([db tableExists:[[object class] tableName]]) {
            successed = [db executeUpdate:sql];
            if (!successed) {
                result = [PPSqliteORMError errorWithCode:PPSqliteORMWriteFailed];
            }
        } else {
            successed = NO;
            result = [PPSqliteORMError errorWithCode:PPSqliteORMUsedWithoutRegister];
        }
        
        if (complete) complete(successed, result);
    }];
}

- (void)writeObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete {
    if ([objects count]) {
        NSString* tableName = [[objects firstObject] tableName];
        [_fmdbQueue inDatabase:^(FMDatabase *db) {
            if (![db tableExists:tableName]) {
                if (complete) complete(NO, [PPSqliteORMError errorWithCode:PPSqliteORMUsedWithoutRegister]);
                return;
            }

            [_fmdbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                BOOL successed = YES;
                for (NSObject<PPSqliteORMProtocol> * object in objects) {
                    successed = [db executeUpdate:[PPSqliteORMSQL sqlForInsert:object]];
                    if (!successed) {
                        *rollback = YES;
                        if (complete) complete(NO, [PPSqliteORMError errorWithCode:PPSqliteORMWriteFailed]);
                        return;
                    }
                }
                
                if (complete) complete(YES, nil);
            }];

        }];
        
    } else {
        if (complete) complete(YES, nil);
    }
}

- (void)deleteObject:(id)object complete:(PPSqliteORMComplete)complete {
}

- (void)deleteObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete {
}

- (void)read:(Class)clazz filter:(NSString* )condition complete:(PPSqliteORMComplete)complete {
}

@end
