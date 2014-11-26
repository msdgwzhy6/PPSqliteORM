//
//  PPSqliteORMError.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/26.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEF(__code, __description) __code

enum {
    DEF(PPSqliteORMRegisterFailed = -100,   @"Create database table failed."),
    DEF(PPSqliteORMUnregisterFailed,        @"Drop database table failed."),
    DEF(PPSqliteORMUsedWithoutRegister,     @"Didn't register the class."),
    DEF(PPSqliteORMWriteFailed,             @"Insert failed."),
    DEF(PPSqliteORMNotAssignPrimaryKey,     @"Not assign primary key."),
    DEF(PPSqliteORMDeleteFailed,            @"Delete failed."),

};

#define PPSqliteORMErrorMacro(__code) [PPSqliteORMError errorWithCode:__code]

@interface PPSqliteORMError : NSError

+ (id)errorWithCode:(NSInteger)code;

@end
