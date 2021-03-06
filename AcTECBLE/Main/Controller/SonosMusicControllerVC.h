//
//  SonosMusicControllerVC.h
//  AcTECBLE
//
//  Created by AcTEC on 2020/9/25.
//  Copyright © 2020 AcTEC ELECTRONICS Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SonosMusicControllerVC : UIViewController

@property (nonatomic,strong)NSNumber *deviceId;
@property (nonatomic,copy) void (^reloadDataHandle)(void);

@end

NS_ASSUME_NONNULL_END
