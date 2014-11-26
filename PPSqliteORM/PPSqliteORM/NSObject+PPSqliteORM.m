//
//  NSObject+PPSqliteORM.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "NSObject+PPSqliteORM.h"
#import <objc/runtime.h>

@implementation NSObject (PPSqliteORM)

+ (NSString* )tableName {
    NSString* tableName;
    if ([self respondsToSelector:@selector(registerName)]) {
        tableName = [[self class] registerName];
    } else {
        tableName = NSStringFromClass([self class]);
    }
    return tableName;
}

+ (NSDictionary* )variableMap {
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    
    unsigned int numIvars = 0;
    Class clazz = [self class];
    
    do {
        Ivar * ivars = class_copyIvarList(clazz, &numIvars);
        if (ivars) {
            for(int i = 0; i < numIvars; i++) {
                Ivar thisIvar = ivars[i];
                const char *type = ivar_getTypeEncoding(thisIvar);
                NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
                NSString* key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                
                if ([stringType hasPrefix:@"@"]) {
                    stringType = [stringType substringWithRange:NSMakeRange(2, stringType.length-3)];
                } else if ([stringType hasPrefix:@"\""]) {
                    stringType = [stringType substringWithRange:NSMakeRange(1, stringType.length-2)];
                }
                map[key] = stringType;
            }
            free(ivars);
        }
        
        clazz = class_getSuperclass(clazz);
    } while(clazz && strcmp(object_getClassName(clazz), "NSObject"));
    
    return [NSDictionary dictionaryWithDictionary:map];
}

- (NSString* )sqlValue {
    return nil;
}

+ (id)valueForSQL:(NSString* )sql {
    return nil;
}

@end
