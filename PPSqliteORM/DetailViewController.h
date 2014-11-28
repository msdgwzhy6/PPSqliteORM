//
//  DetailViewController.h
//  PPSqliteORM
//
//  Created by StarNet on 14/11/28.
//  Copyright (c) 2014年 StarNet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, assign) IBOutlet UISwitch* sexSwitch;
@property (nonatomic, assign) IBOutlet UITextField* ageTextField;
@property (nonatomic, assign) IBOutlet UITextField* nameTextField;
@property (nonatomic, assign) IBOutlet UITextField* codeTextField;
@property (nonatomic, assign) IBOutlet UITextField* schoolTextField;
@property (nonatomic, assign) IBOutlet UIDatePicker* brithdayPicker;

@end
