//
//  PPSqliteORMManager.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPSqliteORMProtocol.h"

/**
 * callback block, when successed = NO, result is PPSqliteORMError object.
 */
typedef void(^PPSqliteORMComplete)(BOOL successed, id result);

@interface PPSqliteORMManager : NSObject

+ (id)defaultManager;

- (void)registerClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete;
- (void)unregisterClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete;

- (void)writeObject:(id <PPSqliteORMProtocol>)object complete:(PPSqliteORMComplete)complete;
- (void)writeObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete;

- (void)deleteObject:(id <PPSqliteORMProtocol>)object complete:(PPSqliteORMComplete)complete;
- (void)deleteObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete;

- (void)read:(Class <PPSqliteORMProtocol>)clazz filter:(NSString* )condition complete:(PPSqliteORMComplete)complete;

@end
