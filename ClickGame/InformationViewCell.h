//
//  InformationViewCell.h
//  ClickGame
//
//  Created by Admin on 05.09.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsForLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *PointsForClickLabel;

@end
