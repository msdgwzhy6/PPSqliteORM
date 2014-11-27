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

/**
 * Register class to database.
 * 
 * @param clazz         The class will be registered
 * @param complete      Callback for complete
 */
- (void)registerClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete;

/**
 * Unregister class from database.
 *
 * @param clazz         The class will be unregistered
 * @param complete      Callback for complete
 */
- (void)unregisterClass:(Class <PPSqliteORMProtocol>)clazz complete:(PPSqliteORMComplete)complete;

/**
 * Write the object to database.
 *
 * @param object        The object which will be writed to database
 * @param complete      Callback for complete
 */
- (void)writeObject:(id <PPSqliteORMProtocol>)object complete:(PPSqliteORMComplete)complete;

/**
 * Write the objects to database.
 *
 * @param objects       The array contain object which will be writed to database
 * @param complete      Callback for complete
 *
 * @Note The objects of array must be same belong to same class
 */
- (void)writeObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete;

/**
 * Delete object from databse.
 *
 * @param clazz         The object which will be delete from database
 * @param complete      Callback for complete
 */
- (void)deleteObject:(id <PPSqliteORMProtocol>)object complete:(PPSqliteORMComplete)complete;

/**
 * Delete objects from databse.
 *
 * @param clazz         The array contain object which will be delete from database
 * @param complete      Callback for complete
 *
 * @Note The objects of array must be same belong to same class
 */
- (void)deleteObjects:(NSArray* )objects complete:(PPSqliteORMComplete)complete;

/**
 * Read object from database.
 *
 * @param clazz         Assign the class
 * @param condition     SQL condition(like and, or, group by, order by, =, >, < and so)
 * @param complete      Callback for complete
                        result is the NSArray of object.
 */
- (void)read:(Class <PPSqliteORMProtocol>)clazz condition:(NSString* )condition complete:(PPSqliteORMComplete)complete;

/**
 * Get the count of the clazz under the condition
 *
 * @param clazz         Assign the class
 * @param condition     SQL condition(like and, or, group by, order by, =, >, < and so)
 * @param complete      Callback for complete
 *                      result is NSNumber(int) of count
 */
- (void)count:(Class <PPSqliteORMProtocol>)clazz condition:(NSString* )condition complete:(PPSqliteORMComplete)complete;

@end
