//
//  ScanViewController.h
//  SocketDemo
//
//  Created by AcTEC on 2018/11/29.
//  Copyright © 2018 BAO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanViewController : UIViewController

@property (nonatomic,copy) void (^scanVCHandle)(void);

@end

NS_ASSUME_NONNULL_END
