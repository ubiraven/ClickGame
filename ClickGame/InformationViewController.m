//
//  InformationViewController.m
//  ClickTest
//
//  Created by Admin on 03.09.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import "InformationViewController.h"
#define ReusableView @"Cell"
#define Level @"Level"
#define PointsForOneClick @"PointsForOneClick"
#define PointsForLevel @"PointsForLevel"

@interface InformationViewController ()

@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - table view data methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayWithData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusableView forIndexPath:indexPath];
    //заполнение данных ячейки
    cell.levelLabel.text = [NSString stringWithFormat:@"%d",[[[_arrayWithData objectAtIndex:indexPath.row]objectForKey:Level]intValue]];
    cell.pointsForLevelLabel.text = [NSString stringWithFormat:@"%d",[[[_arrayWithData objectAtIndex:indexPath.row]objectForKey:PointsForLevel]intValue]];
    cell.PointsForClickLabel.text = [NSString stringWithFormat:@"%d",[[[_arrayWithData objectAtIndex:indexPath.row]objectForKey:PointsForOneClick]intValue]];

    return cell;
}

#pragma mark - методы для эффекта нажатия кнопки
//убрать тень при нажатии
- (IBAction)buttonIsPushed:(UIButton *)sender {
    sender.layer.shadowOpacity = 0.0;
}
//вернуть, когда отпустили
- (IBAction)buttonIsFinishedPushing:(UIButton *)sender {
    sender.layer.shadowOpacity = 1.0;
}

@end
