//
//  Person.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/27.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) BOOL sex;
@property (nonatomic, assign) NSInteger age;

@end
