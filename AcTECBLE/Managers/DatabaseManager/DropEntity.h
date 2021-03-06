//
//  DropEntity.h
//  AcTECBLE
//
//  Created by AcTEC on 2018/1/2.
//  Copyright © 2018年 AcTEC ELECTRONICS Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DropEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * boundRatio;
@property (nonatomic, retain) NSNumber * centerXRatio;
@property (nonatomic, retain) NSNumber * centerYRatio;
@property (nonatomic, retain) NSNumber * dropID;
@property (nonatomic, retain) NSNumber * galleryID;
@property (nonatomic, retain) NSNumber * deviceID;
@property (nonatomic, retain) NSString * kindName;
@property (nonatomic, retain) NSNumber * channel;

@end
