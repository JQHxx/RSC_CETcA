//
//  PlaceDetailsViewController.h
//  AcTECBLE
//
//  Created by AcTEC on 2017/12/26.
//  Copyright © 2017年 AcTEC(Fuzhou) Electronics Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSRCheckbox.h"
#import "CSRPlaceEntity.h"

@interface PlaceDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *placeNameTF;
@property (weak, nonatomic) IBOutlet UITextField *placeNetworkKeyTF;
@property (weak, nonatomic) IBOutlet CSRCheckbox *showPasswordCheckbox;
@property (nonatomic,strong) CSRPlaceEntity *placeEntity;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *networkKeyLabel;
@property (weak, nonatomic) IBOutlet UILabel *showPasswordLabel;
@property (weak, nonatomic) IBOutlet UIView *passwordLineView;
@property (nonatomic,copy) void (^placeDetailVCHandle)(void);

@end
