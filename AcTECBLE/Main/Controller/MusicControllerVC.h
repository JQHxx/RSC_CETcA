//
//  MusicControllerVC.h
//  AcTECBLE
//
//  Created by AcTEC on 2020/8/14.
//  Copyright © 2020 AcTEC ELECTRONICS Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicControllerVC : UIViewController

@property (nonatomic,strong)NSNumber *deviceId;
@property (nonatomic,copy) void (^reloadDataHandle)(void);
@property (nonatomic, assign) NSInteger channel;

@end

NS_ASSUME_NONNULL_END
