//
//  ClickMainViewController.m
//  ClickTest
//
//  Created by Admin on 01.09.15.
//  Copyright (c) 2015 ArtemyevSergey. All rights reserved.
//

#import "ClickMainViewController.h"

#define ClickButtonTag 100                       //tags для view
#define ViewWithPointsTag 101
#define PointsViewSizeRatioToMainWindow 5        //отношение размера вида со всплывающими цифрами к ширине экрана
#define FontRatioToView 1.3                      //отношение размера шрифта к размеру view
#define iPadFont 70.0                            //шрифт для iPad
#define Level @"Level"                           //текстовые константы
#define Points @"Points"
#define PointsForOneClick @"PointsForOneClick"
#define PointsForLevel @"PointsForLevel"
#define Data @"Data"
#define DataSource @"https://raw.githubusercontent.com/ubiraven/ClickTestData/master/data"
#define SegueIdentifier @"InformationView"

@interface ClickMainViewController ()

@end

static BOOL hostWithDataIsReachable;      //флаг наличия доступа к сети
static float screenWidth;                 //ширина экрана
static float pointsViewWidth;             //геометрия всплывающего вида
static float pointsViewHeight;
static float pointsViewOriginY;
static int pointsViewFontSize;
static NSArray *arrayWithColors;          //массив с цветами для циферок
static int pushingCounter;                //счетчик нажатий(для смены цвета циферок)


@implementation ClickMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //инициализация объекта для работы с сетью, попытка загрузки сохраненных данных предыдущей игры(загружаем значения и очков и уровня, либо обнуляем и то, и то), загрузка данных для работы приложения
    _internerReachability = [Reachability reachabilityForInternetConnection];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Level]) {
        _level = [[[NSUserDefaults standardUserDefaults]objectForKey:Level]intValue];
        //NSLog(@"loading saved level");
    }
    if (_level) {
        _points = [[[NSUserDefaults standardUserDefaults]objectForKey:Points]intValue];
        //NSLog(@"loading saved points");
    }
    if (!_points) {
        _level = 1.0;
        _points = 0.0;
    }
    [self loadingData];
    
    //замена шрифта на iPad на более большой
    //NSLog(@"%@",[[UIDevice currentDevice]model]);
    if ([[[UIDevice currentDevice]model] isEqualToString:@"iPad"] ||
        [[[UIDevice currentDevice]model] isEqualToString:@"iPad Simulator"]) {
        _scoreLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:iPadFont];
        _levelLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:iPadFont];
    }
    //инициализация массива с цветами
    arrayWithColors = [NSArray arrayWithObjects:[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor redColor], nil];
    
    //вычисление размера всплывающего вида, в зависимости от ширины устройства в портретной ориентации
    screenWidth = self.view.frame.size.width;
    pointsViewWidth = screenWidth / PointsViewSizeRatioToMainWindow;
    pointsViewHeight = pointsViewWidth;
    pointsViewFontSize = pointsViewHeight / FontRatioToView;
    //определение ориентации устройства при старте, для задания значения координаты Y
    CGSize screenSize;
    switch ([[UIApplication sharedApplication]statusBarOrientation]) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            screenSize.height = self.view.frame.size.width;
            screenSize.width = self.view.frame.size.height;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            screenSize.height = self.view.frame.size.height;
            screenSize.width = self.view.frame.size.width;
            break;
        default:
            break;
    }
    screenWidth = screenSize.width;
    //NSLog(@"%f",screenWidth);
    pointsViewOriginY = screenSize.height / 2.0 - pointsViewHeight / 2.0;
    
    //сообщения посылает AppDelegate
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveData) name:@"SaveData" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self saveData];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveData];
}

#pragma mark - загрузка и сохранение данных
- (void)loadingData{
    //проверка наличия сети
    NetworkStatus status = _internerReachability.currentReachabilityStatus;
    switch (status) {
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            //NSLog(@"Host Is Reachable");
            hostWithDataIsReachable = YES;
            break;
            
        case NotReachable:
        default:
            //NSLog(@"Host Is UnReachable");
            hostWithDataIsReachable = NO;
            break;
    }
    
    //если есть - пробуем загрузить данные из интернета
    if (hostWithDataIsReachable) {
        NSError *error = nil;
        NSURL *url = [NSURL URLWithString:DataSource];
        NSData *json = [NSData dataWithContentsOfURL:url];
        _levelsAndPointsValues = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
        if (error) {
            //при ошибке - попытка загрузить сохраненные ранее данные на устройстве
            //NSLog(@"Failed to Load Data");
            //NSLog(@"Trying to Load Data from Device");
            _levelsAndPointsValues = [[NSUserDefaults standardUserDefaults]objectForKey:Data];
        }else{
            //в случае успешной загрузки - сохраняем полученные данные на устройстве
            //NSLog(@"Success: loading and saving data");
            //NSLog(@"%@",_levelsAndPointsValues);
            [[NSUserDefaults standardUserDefaults]setObject:_levelsAndPointsValues forKey:Data];
        }
    //если сети нет - попытка загрузить данные с устройства
    }else{
        //NSLog(@"Trying to Load Data from Device");
        _levelsAndPointsValues = [[NSUserDefaults standardUserDefaults]objectForKey:Data];
    }
    
    //если данные загрузились - заполнение свойств для работы приложения, нет - вывод алерта
    if (_levelsAndPointsValues) {
        _pointsForWin = [[[_levelsAndPointsValues objectAtIndex:_levelsAndPointsValues.count - 1]objectForKey:PointsForLevel]intValue];
        [self setValuesForLevel:_level andPoints:_points];
        //это только для работы с алерт вью
        _clickButton.enabled = YES;
        _clickButton.backgroundColor = [UIColor greenColor];
    }else{
        [self presentNotificationAboutLackingOfData];
    }
}
- (void)saveData{
    //NSLog(@"saving data");
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:(_level)] forKey:Level];
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:(_points)] forKey:Points];
}

#pragma mark - алерт виды
//алерт вью, при закрытии, запустит через минуту новую попытку загрузки данных
- (void)presentNotificationAboutLackingOfData{
    //NSLog(@"Failed to Load any Data, can't continue forward");
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Ошибка!" message:@"Невозможно продолжить игру, данные не загрузились" delegate:self cancelButtonTitle:@"Закрыть" otherButtonTitles:nil, nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Ошибка!"]) {
        _clickButton.enabled = NO;
        _clickButton.backgroundColor = [UIColor grayColor];
        [self performSelector:@selector(loadingData) withObject:nil afterDelay:60.0];
    }
    //алерт вью, запускающий новую игру
    if ([alertView.title isEqualToString:@"Поздравляем!"]){
        _level = 1;
        _points = 0;
        [self setValuesForLevel:_level andPoints:_points];
    }
}

#pragma mark - методы для обработки ротации устройства
//для ios 8 и выше
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self adjustViewsWithPointsForNewScreenSize:size];
    //NSLog(@"version 8.0");
}
//все что ниже
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    //вычисление нового размера экрана
    CGSize newScreenSize;
    switch ([[UIApplication sharedApplication]statusBarOrientation]) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            newScreenSize.height = self.view.frame.size.width;
            newScreenSize.width = self.view.frame.size.height;
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            newScreenSize.height = self.view.frame.size.height;
            newScreenSize.width = self.view.frame.size.width;
            break;
        default:
            break;
    }
    [self adjustViewsWithPointsForNewScreenSize:newScreenSize];
    //NSLog(@"version 7.0");
}
//подгонка всплывающих видов под новый экран
- (void)adjustViewsWithPointsForNewScreenSize:(CGSize)size{
    int oldScreenWidth = screenWidth;
    screenWidth = size.width;
    pointsViewOriginY = size.height / 2.0 - pointsViewHeight / 2.0;
    NSArray *arrayWithViews = [self.view subviews];
    for (UIView *view in arrayWithViews) {
        if (view.tag == ViewWithPointsTag) {
            CGRect rect = view.frame;
            rect.origin.y = pointsViewOriginY;
            rect.origin.x = view.frame.origin.x * screenWidth / oldScreenWidth;
            view.frame = rect;
        }
    }
}

#pragma mark - Navigation
//передача данных для экрана со справкой
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:SegueIdentifier]) {
        InformationViewController *newController = [segue destinationViewController];
        newController.arrayWithData = _levelsAndPointsValues;
    }
}
//закрытие экрана справки
- (IBAction)unwindToClickMainView:(UIStoryboardSegue*)sender{
}

#pragma mark - методы нажатия кнопок и обработки связанных событий
- (IBAction)buttonIsPushed:(UIButton *)sender {
    //убрать тень от кнопки
    sender.layer.shadowOpacity = 0.0;
}
- (IBAction)buttonIsFinishedPushing:(UIButton *)sender {
    //вернуть тень
    sender.layer.shadowOpacity = 1.0;
    //вывести на экран вид с цифрой
    if (sender.tag == ClickButtonTag) {
        [self pushViewOnScreenWithPoints:sender.titleLabel.text andTextColor:[arrayWithColors objectAtIndex:pushingCounter]];
        pushingCounter += 1;
        if (pushingCounter == 4) {
            pushingCounter = 0;
        }
        //расчет новых значений
        _points += [sender.titleLabel.text intValue];
        _scoreLabel.text = [NSString stringWithFormat:@"Score: %i",_points];
        //проверка левел апа
        [self checkLevelUpForPoints:_points];
    }
}
- (void)checkLevelUpForPoints:(int)points {
    //если есть левел ап
    if (points >= _pointsForNextLevel) {
        _level += 1;
        //если игра пройдена - вывод алерт вью и запуск игры по новой
        if (points >= _pointsForWin) {
            //NSLog(@"You have won the game");
            [self setValuesForLevel:_level andPoints:_points];
            if ([[[UIDevice currentDevice]systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Поздравляем!" message:@"Вы прошли игру!" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Начать заново" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                    _level = 1;
                    _points = 0;
                    [self setValuesForLevel:_level andPoints:_points];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Поздравляем!" message:@"Вы прошли игру!" delegate:self cancelButtonTitle:@"Начать заново" otherButtonTitles:nil, nil];
                [alertView show];
            }
        //если игра еще не пройдена - установка новых значений для игры
        }else{
            [self setValuesForLevel:_level andPoints:_points];
        }
    }
}
//заполнение свойств для работы игры, в зависимости от уровня и кол-ва очков
- (void)setValuesForLevel:(int)level andPoints:(int)points{
    _pointsForOneClick = [[[_levelsAndPointsValues objectAtIndex:level - 1]objectForKey:PointsForOneClick] intValue];
    if (points < _pointsForWin) {
        _pointsForNextLevel = [[[_levelsAndPointsValues objectAtIndex:level]objectForKey:PointsForLevel] intValue];
    }
    [_clickButton setTitle:[NSString stringWithFormat:@"%i",_pointsForOneClick] forState:UIControlStateNormal];
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %i",points];
    _levelLabel.text = [NSString stringWithFormat:@"Level: %i",level];
}

#pragma mark - вывод на экран вида с цифрами
- (void)pushViewOnScreenWithPoints:(NSString*)points andTextColor:(UIColor*)color {
    //вычисление координаты X
    float pointsViewOriginX = arc4random_uniform(screenWidth + 1.0 - pointsViewWidth);
    //NSLog(@"%f",pointsViewOriginX);
    //создание вида и настройка
    UILabel *pointView = [[UILabel alloc]initWithFrame:CGRectMake(pointsViewOriginX, pointsViewOriginY, pointsViewWidth, pointsViewHeight)];
    pointView.tag = ViewWithPointsTag;
    pointView.text = points;
    pointView.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:pointsViewFontSize];
    pointView.textAlignment = NSTextAlignmentCenter;
    pointView.backgroundColor = [UIColor clearColor];
    pointView.textColor = color;
    //NSLog(@"%@",self.view.subviews);
    [self.view addSubview:pointView];
   // NSLog(@"%@",self.view.subviews);
    //анимация затухания вида
    [UIView animateWithDuration:2.0 delay:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
        pointView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [pointView removeFromSuperview];
    }];
   // NSLog(@"%@",self.view.subviews);
}

@end
