//
//  Student.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/27.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "Person.h"

@interface Student : Person

@property (nonatomic, strong) NSString* codeTest;
@property (nonatomic, strong) NSString* schoolName;

@property (nonatomic, strong) NSDictionary* info;

@end
