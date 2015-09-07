//
//  ClickMainViewController.h
//  ClickTest
//
//  Created by Admin on 01.09.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "InformationViewController.h"

@interface ClickMainViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;      //элементы интерфейса
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UIButton *clickButton;
@property (nonatomic) int points;                               //данные для игры
@property (nonatomic) int level;
@property (nonatomic) int pointsForOneClick;
@property (nonatomic) int pointsForNextLevel;
@property (nonatomic) int pointsForWin;
@property (strong, nonatomic) NSArray *levelsAndPointsValues;     //массив с данными
@property (strong, nonatomic) Reachability *internerReachability; //контроль доступа к интернету

- (IBAction)buttonIsPushed:(UIButton *)sender;
- (IBAction)buttonIsFinishedPushing:(UIButton *)sender;


@end
