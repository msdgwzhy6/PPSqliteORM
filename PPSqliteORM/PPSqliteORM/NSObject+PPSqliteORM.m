/**
 * NSObject+PPSqliteORM.m
 *
 * Extension of NSObject for get necessary from model class.like tableName, primary key.
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

+ (NSString* )primary {
    NSString* primaryKey;
    if ([(NSObject*)[self class] respondsToSelector:@selector(primaryKey)]) {
        primaryKey = [[self class] primaryKey];
    }
    return primaryKey;
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
