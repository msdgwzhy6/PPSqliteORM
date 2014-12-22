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

PPSqliteORMAsignRegisterName(@"student");
PPSqliteORMAsignPrimaryKey(code);

- (NSString* )description {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    return [NSString stringWithFormat:@"name=%@, sex=%d, age=%ld, brithday=%@, code=%@, school=%@, info=%@", self.name, self.sex, (long)self.age, [dateFormatter stringFromDate:self.brithday], self.code, self.school, self.info];
}

@end
