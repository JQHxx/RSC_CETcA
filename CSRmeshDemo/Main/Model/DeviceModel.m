//
//  DeviceModel.m
//  CSRmeshDemo
//
//  Created by AcTEC on 2017/9/20.
//  Copyright © 2017年 AcTEC(Fuzhou) Electronics Co., Ltd. All rights reserved.
//

#import "DeviceModel.h"

@implementation DeviceModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mcChannel = 0;
        self.mcCurrentChannel = -1;
        self.mcStatus = -1;
        self.mcVoice = -1;
    }
    return self;
}

@end

