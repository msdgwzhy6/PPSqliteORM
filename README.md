# PPSqliteORM

## Description
	
PPSqliteORM is ORM(Object/Relation Mapping) operation for sqlite. PPSqliteORM provide a very easy way to operate sqlite database.

## Getting Start

<pre>
	//import header
	#import "PPSqliteORM.h"

	//obtain manager
    PPSqliteORMManager* manager = [PPSqliteORMManager defaultManager];
    
    //register
    [manager registerClass:[Student class] complete:NULL];
    
    Student* stu = [[Student alloc] init];
    ...
    
    //write to database
    [manager writeObject:stu complete:^(BOOL successed, id result) {
    	//result
    }];
    
    ...
    
    //read
    [manager read:[Student class] condition:@"_code = '201410'" complete:^(BOOL successed, id result) {
    	//result
    	//Student* stu = [result firstObject];
    }

	//if you don't needs the model data, unregister it
	[manager unregisterClass:[Student class] complete:NULL];
</pre>

## Debug
If you want to debug, turn on PPSqliteORMDebugEnable
<pre>
#define PPSqliteORMDebugEnable    1
</pre>

## Model Class Define
* Currently support follow type:

|Object Type|SQL Type|Format
|:---|:---|:---|
|char|INTEGER|
|unsigned char|INTEGER|
|short|INTEGER|
|unsigned short|INTEGER|
|int|INTEGER|
|unsigned int|INTEGER|
|NSInteger|INTEGER|
|BOOL|INTEGER|
|float|REAL|
|double|REAL|
|NSString|TEXT|
|NSMutableString|TEXT
|NSDate|REAL|
|NSNumber|INTEGER|


## License

Under the MIT License.

