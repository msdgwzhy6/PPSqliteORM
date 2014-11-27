//
//  Student.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/27.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "Student.h"
#import "PPSqliteORM.h"

@implementation Student

PPSqliteORMAsignPrimaryKey(_code);

- (NSString* )description {
    return [NSString stringWithFormat:@"name=%@, sex=%d, age=%d, code=%@, school=%@", self.name, self.sex, self.age, self.code, self.school];
}

@end
