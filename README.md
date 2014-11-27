# PPSqliteORM

## Description
	
PPSqliteORM is ORM(Object/Relation Mapping) operation for sqlite. PPSqliteORM provide a very easy way to operate sqlite database.

## Getting Start
#### (1) Obtain PPSqliteORM Manager
<pre>
PPSqliteORMManager* manager = [PPSqliteORMManager defaultManager];
</pre>
#### (2) Define the Model Class
<pre>
#import "Person.h"

@interface Student : Person

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* school;

@end
</pre>
PS: You can use PPSqliteORMAsignPrimaryKey to assign the primary key. Also you can use PPSqliteORMAsignRegisterName to assign the register name.

<pre>
#import "Student.h"
#import "PPSqliteORM.h"

@implementation Student

PPSqliteORMAsignRegisterName(@"student");
PPSqliteORMAsignPrimaryKey(_code);

@end
</pre>

#### (3) Register the Model Class
<pre>
[manager registerClass:[Student class] complete:^(BOOL successed, id result) {
	//if successed = YES, means register success.
}];
</pre>

#### (4) Write object
<pre>
NSMutableArray* array = [NSMutableArray array];

int num = 100;
for (int i = 0; i \< num; i++) {
    Student* stu = [[Student alloc] init];
    stu.name = [NSString stringWithFormat:@"学生%d", i];
    stu.sex = rand()&0x1?YES:NO;
    stu.age = rand()%100+1;
    stu.code = [NSString stringWithFormat:@"2014%d", i];
    stu.school = @"福州一中";
    [array addObject:stu];
}
[manager writeObjects:array complete:^(BOOL successed, id result) {
    //result
}];
</pre>

#### (5) Read object
<pre>
[manager read:[Student class] condition:@"_code = '201410'" complete:^(BOOL successed, id result) {
	if ([result count]) {
    	Student* stu = [result firstObject];
    }
}];
</pre>

#### (6) Count
<pre>
[manager count:[Student class] condition:nil complete:^(BOOL successed, id result) {
    //result is NSNumber of count.
}];

</pre>

#### (7) Unregister the Model Class
If you are not already use the model data. you can use to delete all data of this model.
<pre>
[manager unregisterClass:[Student class] complete:^(BOOL successed, id result) {
	//...
}];
</pre>

## License

Under the MIT License.

