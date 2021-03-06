//
//  GalleryDetailViewController.h
//  AcTECBLE
//
//  Created by AcTEC on 2018/1/2.
//  Copyright © 2017年 AcTEC(Fuzhou) Electronics Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GalleryDetailViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) NSMutableArray *drops;
@property (nonatomic, strong) void(^handle)(void);
@property (nonatomic, strong) NSNumber *galleryId;
@property (nonatomic, assign) BOOL isNewAdd;

@end
