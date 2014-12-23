//
//  PPSqliteORMTests.m
//  PPSqliteORMTests
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PPSqliteORM.h"
#import "Student.h"
#import "Teacher.h"

@interface PPSqliteORMTests : XCTestCase

@end

@implementation PPSqliteORMTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegister {
    PPSqliteORMManager* manager = [PPSqliteORMManager defaultManager];

    [manager registerClass:[Student class] complete:^(BOOL successed, id result) {
        XCTAssert(successed, @"Register Student class Pass");
    }];
}

- (void)testWriteRead {
    PPSqliteORMManager* manager = [PPSqliteORMManager defaultManager];
    srand((unsigned)time(0));

    NSMutableArray* array = [NSMutableArray array];
    
    int num = 100;
    for (int i = 0; i < num; i++) {
        Student* stu = [[Student alloc] init];
        stu.name = [NSString stringWithFormat:@"学生%d", i];
        stu.sex = rand()&0x1?YES:NO;
        stu.age = rand()%100+1;
        stu.codeTest = [NSString stringWithFormat:@"2014%d", i];
        stu.schoolName = @"福州一中";
        stu.brithday = [NSDate dateWithTimeIntervalSinceNow:i*100];
        stu.info = @{@"hello":@"world"};
        [array addObject:stu];
    }
    
    [manager writeObjects:array complete:^(BOOL successed, id result) {
        XCTAssert(successed, @"Write student ... ");
    }];
    
    [manager count:[Student class] condition:nil complete:^(BOOL successed, id result) {
        XCTAssert(result && ([result intValue] == num), @"Write student Pass");
    }];
    
    //read
    [manager read:[Student class] condition:@"codeTest = '201410'" complete:^(BOOL successed, id result) {
        
        
        XCTAssert(result, @"Pass");
        XCTAssert([result isKindOfClass:[NSArray class]], @"Pass");
        XCTAssert([result count] == 1, @"Pass");
        Student* stu = [result firstObject];
        XCTAssert([stu isKindOfClass:[Student class]], @"Pass");
        XCTAssert([stu.codeTest isEqualToString:@"201410"], @"Pass");
        NSLog(@"stu=%@", stu);
    }];
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
