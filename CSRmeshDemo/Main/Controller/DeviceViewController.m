//
//  DeviceViewController.m
//  CSRmeshDemo
//
//  Created by AcTEC on 2018/1/25.
//  Copyright © 2018年 Cambridge Silicon Radio Ltd. All rights reserved.
//

#import "DeviceViewController.h"
#import "DeviceModelManager.h"
#import "CSRDatabaseManager.h"
#import "CSRUtilities.h"
#import "CSRConstants.h"
#import "DataModelManager.h"

@interface DeviceViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UISwitch *powerStateSwitch;
@property (weak, nonatomic) IBOutlet UISlider *levelSlider;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (nonatomic,assign) BOOL sliderIsMoving;
@property (nonatomic,strong) DeviceModel *device;
@property (nonatomic,copy) NSString *originalName;
@property (weak, nonatomic) IBOutlet UILabel *colorTemperatureLabel;
@property (weak, nonatomic) IBOutlet UIView *colorTemperatureView;

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChange:) name:ZZAppLanguageDidChangeNotification object:nil];
    
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeAction)];
        self.navigationItem.rightBarButtonItem = done;
    }
    
    self.nameTF.delegate = self;
    
    if (_deviceId) {
        _device = [[DeviceModelManager sharedInstance] getDeviceModelByDeviceId:_deviceId];
        if ([CSRUtilities belongToSwitch:_device.shortName]) {
            [self.levelSlider setEnabled:NO];
        }
        
        self.navigationItem.title = _device.name;
        self.nameTF.text = _device.name;
        self.originalName = _device.name;
        self.powerStateSwitch.on = [_device.powerState boolValue];
        self.sliderIsMoving = NO;
        [self powerSwitchAndLevelSlider:_device.shortName powerState:_device.powerState level:_device.level];
        
        if (![CSRUtilities belongToColorTemperatureDevice:_device.shortName]) {
            self.colorTemperatureLabel.hidden = YES;
            self.colorTemperatureView.hidden = YES;
        }

    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setPowerStateSuccess:)
                                                 name:@"setPowerStateSuccess"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"setPowerStateSuccess"
                                                  object:nil];
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)powerSwitchAndLevelSlider:(NSString *)kindString powerState:(NSNumber *)power level:(NSNumber *)level {
    if ([CSRUtilities belongToSwitch:kindString]) {
        if ([power boolValue]) {
            [self.powerStateSwitch setOn:YES];
            [self.levelSlider setValue:255.0f animated:YES];
            self.levelLabel.text = @"100%";
        }else {
            [self.powerStateSwitch setOn:NO];
            [self.levelSlider setValue:0 animated:YES];
            self.levelLabel.text = @"0%";
        }
    }
    else {
        if ([power boolValue]) {
            [self.powerStateSwitch setOn:YES];
            if (!_sliderIsMoving) {
                [self.levelSlider setValue:(CGFloat)[level integerValue] animated:YES];
            }
            self.levelLabel.text = [NSString stringWithFormat:@"%.f%%",[level integerValue]/255.0*100];
        }else {
            [self.powerStateSwitch setOn:NO];
            [self.levelSlider setValue:0 animated:YES];
            self.levelLabel.text = @"0%";
        }
    }
    
}

- (void)setPowerStateSuccess:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *deviceId = userInfo[@"deviceId"];
    if ([deviceId isEqualToNumber:_deviceId]) {
        [self powerSwitchAndLevelSlider:_device.shortName powerState:_device.powerState level:_device.level];
    }
}

- (IBAction)powerStateSwitch:(UISwitch *)sender {
//    _sliderIsMoving = NO;
    [[DeviceModelManager sharedInstance] setPowerStateWithDeviceId:_deviceId withPowerState:@(sender.on)];
}

- (IBAction)levelSliderTouchUpInSide:(UISlider *)sender {
    _sliderIsMoving = NO;
    [[DeviceModelManager sharedInstance] setLevelWithDeviceId:_deviceId withLevel:@(sender.value) withState:UIGestureRecognizerStateEnded direction:PanGestureMoveDirectionHorizontal];
}

- (IBAction)leveSliderValueChanged:(UISlider *)sender {
    [[DeviceModelManager sharedInstance] setLevelWithDeviceId:_deviceId withLevel:@(sender.value) withState:UIGestureRecognizerStateChanged direction:PanGestureMoveDirectionHorizontal];
}

- (IBAction)levelSliderTouchDown:(UISlider *)sender {
    _sliderIsMoving = YES;
    [[DeviceModelManager sharedInstance] setLevelWithDeviceId:_deviceId withLevel:@(sender.value) withState:UIGestureRecognizerStateBegan direction:PanGestureMoveDirectionHorizontal];
}

- (IBAction)levelSliderTouchUpOutSide:(UISlider *)sender {
    _sliderIsMoving = NO;
    [[DeviceModelManager sharedInstance] setLevelWithDeviceId:_deviceId withLevel:@(sender.value) withState:UIGestureRecognizerStateEnded direction:PanGestureMoveDirectionHorizontal];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    textField.backgroundColor = [UIColor whiteColor];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveNickName];
}

#pragma mark - 保存修改后的灯名

- (void)saveNickName {
    if (![_nameTF.text isEqualToString:_originalName] && _nameTF.text.length > 0) {
        self.navigationItem.title = _nameTF.text;
        CSRDeviceEntity *deviceEntity = [[CSRDatabaseManager sharedInstance] getDeviceEntityWithId:self.deviceId];
        deviceEntity.name = _nameTF.text;
        [[CSRDatabaseManager sharedInstance] saveContext];
        DeviceModel *model = [[DeviceModelManager sharedInstance] getDeviceModelByDeviceId:self.deviceId];
        model.name = _nameTF.text;
        if (self.reloadDataHandle) {
            self.reloadDataHandle();
        }
    }
    
}

- (IBAction)colorTemperatureChange:(UIButton *)sender {
    [[DataModelManager shareInstance] changeColorTemperature:_deviceId];
    sender.backgroundColor = [UIColor clearColor];
}
- (IBAction)touchUpOutside:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:234/255.0 green:184/255.0 blue:63/255.0 alpha:1];
}


- (IBAction)colorTemperatureReset:(UIButton *)sender {
    [[DataModelManager shareInstance] resetColorTemperature:_deviceId];
    sender.backgroundColor = [UIColor clearColor];
}

- (void)languageChange:(id)sender {
    if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
}

@end
