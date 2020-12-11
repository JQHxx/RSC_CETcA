//
//  SonosSelectModel.m
//  AcTECBLE
//
//  Created by AcTEC on 2020/11/2.
//  Copyright © 2020 AcTEC ELECTRONICS Ltd. All rights reserved.
//

#import "SonosSelectModel.h"

@implementation SonosSelectModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _source = -1;
        _songNumber = -1;
    }
    return self;
}

@end
