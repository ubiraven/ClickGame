//
//  InformationViewController.h
//  ClickTest
//
//  Created by Admin on 03.09.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InformationViewCell.h"

@interface InformationViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *arrayWithData;           //массив с данными для таблицы
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buttonIsPushed:(UIButton *)sender;
- (IBAction)buttonIsFinishedPushing:(UIButton *)sender;

@end
