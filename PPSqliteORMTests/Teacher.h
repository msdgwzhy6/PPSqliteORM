//
//  Teacher.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/27.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "Person.h"

@interface Teacher : Person

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* school;

@end
