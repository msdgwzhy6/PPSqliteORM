//
//  ViewController.m
//  PPSqliteORM
//
//  Created by StarNet on 14/11/25.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "PPSqliteORM.h"
#import "Student.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate> {
    PPSqliteORMManager* _manager;
    
    NSMutableArray* _tableData;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _manager = [PPSqliteORMManager defaultManager];
    
    [self reload];
}

- (void)reload {
    [_manager read:[Student class] condition:nil complete:^(BOOL successed, id result) {
        _tableData = [NSMutableArray arrayWithArray:result];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (IBAction)onClearButtonPressed:(id)sender {
    [_manager deleteAllObjects:[Student class] complete:^(BOOL successed, id result) {
        [self reload];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Student* stu = _tableData[indexPath.row];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@     %@     %ld     %@", stu.name, stu.sex?@"Girl":@"Boy", (long)stu.age, [dateFormatter stringFromDate:stu.brithday]]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@     %@", stu.schoolName, stu.codeTest]];
    return cell;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    [_tableData removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

@end
