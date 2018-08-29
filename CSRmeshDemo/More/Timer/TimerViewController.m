//
//  TimerViewController.m
//  CSRmeshDemo
//
//  Created by AcTEC on 2017/8/30.
//  Copyright © 2017年 AcTEC(Fuzhou) Electronics Co., Ltd. All rights reserved.
//

#import "TimerViewController.h"
#import "TimerDetailViewController.h"
#import "PureLayout.h"
#import "CSRAppStateManager.h"
#import "TimerTableViewCell.h"
#import "CSRDeviceEntity.h"
#import "DataModelManager.h"

#import "CSRDatabaseManager.h"
#import "CSRUtilities.h"

@interface TimerViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *noneDataView;
@property (nonatomic,strong) NSMutableArray *dataArray;


@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChange) name:ZZAppLanguageDidChangeNotification object:nil];
    self.view.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    self.navigationItem.title = AcTECLocalizedStringFromTable(@"Timer", @"Localizable");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDeviceEntity) name:@"deleteDeviceEntity" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDeviceEntity) name:@"reGetDataForPlaceChanged" object:nil];
    
    if (@available(iOS 11.0, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"Btn_back"] forState:UIControlStateNormal];
        [btn setTitle:AcTECLocalizedStringFromTable(@"Setting", @"Localizable") forState:UIControlStateNormal];
        [btn setTitleColor:DARKORAGE forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backSetting) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem = back;
    }
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick)];
    self.navigationItem.rightBarButtonItem = add;
    
    [self getData];
    [self layoutView];
}

- (void)deleteDeviceEntity {
    [self getData];
    [self layoutView];
}

- (void)backSetting{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromLeft];
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)addClick {
    NSSet *scenes = [CSRAppStateManager sharedInstance].selectedPlace.scenes;
    __block BOOL exit = NO;
    [scenes enumerateObjectsUsingBlock:^(SceneEntity  *scene, BOOL * _Nonnull stop) {
        if ([scene.members count] != 0) {
            exit = YES;
            *stop = YES;
        }
    }];
    if (!exit) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleAlert];
        NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:AcTECLocalizedStringFromTable(@"AllSceneEmpty", @"Localizable")];
        [attributedMessage addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] range:NSMakeRange(0, [[attributedMessage string] length])];
        [alertController setValue:attributedMessage forKey:@"attributedMessage"];
        [alertController.view setTintColor:DARKORAGE];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:AcTECLocalizedStringFromTable(@"Yes", @"Localizable") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:yesAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    TimerDetailViewController *tdvc = [[TimerDetailViewController alloc] init];
    tdvc.newadd = YES;
    __weak TimerViewController *weakSelf = self;
    tdvc.handle = ^{
        [weakSelf getData];
        [weakSelf layoutView];
    };
    
    [self.navigationController pushViewController:tdvc animated:YES];
}

- (void)layoutView {
    if ([self.dataArray count] == 0) {
        [self.view addSubview:self.noneDataView];
        [_noneDataView autoSetDimension:ALDimensionWidth toSize:190.0];
        [_noneDataView autoSetDimension:ALDimensionHeight toSize:262.0];
        [_noneDataView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_noneDataView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:119.0];
        [self.tableView removeFromSuperview];
    }else {
        [self.view addSubview:self.tableView];
        [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [self.noneDataView removeFromSuperview];
    }
    [self.tableView reloadData];
}


- (void)getData {
    
    NSMutableArray *timerMutableArray = [[[CSRAppStateManager sharedInstance].selectedPlace.timers allObjects] mutableCopy];
    
    if (timerMutableArray != nil || [timerMutableArray count] != 0 ) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timerID" ascending:YES];
        [timerMutableArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        self.dataArray = timerMutableArray;
        
    }
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (TimerTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimerTableViewCell" forIndexPath:indexPath];
    TimerEntity *timerEntity = [_dataArray objectAtIndex:indexPath.row];
    [cell configureCellWithInfo:timerEntity];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TimerDetailViewController *tdvc = [[TimerDetailViewController alloc] init];
    TimerEntity *timerEntity = [_dataArray objectAtIndex:indexPath.row];
    tdvc.timerEntity = timerEntity;
    tdvc.newadd = NO;
    __weak TimerViewController *weakSelf = self;
    tdvc.handle = ^{
        [weakSelf getData];
        [weakSelf layoutView];
    };
    [self.navigationController pushViewController:tdvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Lazy

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 88.0f;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerNib:[UINib nibWithNibName:@"TimerTableViewCell" bundle:nil] forCellReuseIdentifier:@"TimerTableViewCell"];
    }
    return _tableView;
}

- (UIView *)noneDataView {
    if (!_noneDataView) {
        _noneDataView = [[UIView alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"Timer_bg"];
        [_noneDataView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = AcTECLocalizedStringFromTable(@"TimerIntroduce", @"Localizable");
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        label.numberOfLines = 0;
        [_noneDataView addSubview:label];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:AcTECLocalizedStringFromTable(@"AddTimer", @"Localizable") forState:UIControlStateNormal];
        [btn setTitleColor:DARKORAGE forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
        [_noneDataView addSubview:btn];
        
        [imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_noneDataView];
        [imageView autoSetDimension:ALDimensionHeight toSize:172.0];
        [imageView autoSetDimension:ALDimensionWidth toSize:172.0];
        [imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:imageView withOffset:20.0];
        [label autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [label autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [label autoSetDimension:ALDimensionHeight toSize:40];
        [btn autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [btn autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [btn autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [btn autoSetDimension:ALDimensionHeight toSize:30];
        
    }
    return _noneDataView;
}

- (void)languageChange {
    self.navigationItem.title = AcTECLocalizedStringFromTable(@"Timer", @"Localizable");
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:AcTECLocalizedStringFromTable(@"Setting_back", @"Localizable")] style:UIBarButtonItemStylePlain target:self action:@selector(backSetting)];
        self.navigationItem.leftBarButtonItem = left;
    }
    if (_noneDataView) {
        [_noneDataView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)obj;
                label.text = AcTECLocalizedStringFromTable(@"TimerIntroduce", @"Localizable");
            }else if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)obj;
                [btn setTitle:AcTECLocalizedStringFromTable(@"AddTimer", @"Localizable") forState:UIControlStateNormal];
            }
        }];
    }
    if (_tableView) {
        [_tableView reloadData];
    }
}

@end
