//
//  PPSqliteORMSQL.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/26.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPSqliteORMProtocol.h"

@interface PPSqliteORMSQL : NSObject

+ (NSString* )sqlForQueryAllTables;
+ (NSString* )sqlForCreateTable:(Class<PPSqliteORMProtocol>)clazz;
+ (NSString* )sqlForDropTable:(Class<PPSqliteORMProtocol>)clazz;
+ (NSString* )sqlForInsert:(id<PPSqliteORMProtocol>)object;
+ (NSString* )sqlForDelete:(id<PPSqliteORMProtocol>)object;
+ (NSString* )sqlForQuery:(Class<PPSqliteORMProtocol>)clazz where:(NSString* )condition;
+ (NSString* )sqlForCount:(Class<PPSqliteORMProtocol>)clazz where:(NSString* )condition;

@end
