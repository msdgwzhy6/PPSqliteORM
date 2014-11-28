//
//  Student.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/27.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "Person.h"

@interface Student : Person

@property (nonatomic, strong) NSMutableString* xxx;
@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* school;
@property (nonatomic, assign) float score;
@property (nonatomic, assign) int aa;

@property (nonatomic, strong) NSDate* finishDate;
@property (nonatomic, assign) Point rect;
@property (nonatomic, assign) Rect re;

@end
