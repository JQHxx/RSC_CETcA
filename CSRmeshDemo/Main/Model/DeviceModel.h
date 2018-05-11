//
//  DeviceModel.h
//  CSRmeshDemo
//
//  Created by AcTEC on 2017/9/20.
//  Copyright © 2017年 Cambridge Silicon Radio Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

@property (nonatomic, strong) NSNumber *deviceId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *powerState;
@property (nonatomic, assign) BOOL isForGroup;
@property (nonatomic, assign) BOOL isShowDeleteBtn;
@property (nonatomic, assign) BOOL isleave;

@end
