//
//  PPSqliteORMProtocol.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#define PPSqliteORMAsignPrimaryKey(__key) \
+ (NSString* )primaryKey { \
return @(#__key); \
}\
- (void)__hint {self->__key;}

#define PPSqliteORMAsignRegisterName(__name) \
+ (NSString* )registerName { \
return __name; \
}

#define CompileErrorBlocked \
+ (NSDictionary* )variableMap;\
+ (NSString* )tableName;

/**
 * Model class need implement this protocol.The Model class should inherit NSObject.
 */

@protocol PPSqliteORMProtocol <NSObject>


@optional

/**
 * Assign the table name for the class, please use macro PPSqliteORMAsignRegisterName. if not assign, will use class name for instead.
 */
+ (NSString* )registerName;

/**
 * Assign the primary key for table, please use macro PPSqliteORMAsignPrimaryKey.
 */
+ (NSString* )primaryKey;


CompileErrorBlocked
@end
