//
//  ColorSlider.m
//  AcTECBLE
//
//  Created by AcTEC on 2018/8/8.
//  Copyright © 2018年 AcTEC ELECTRONICS Ltd. All rights reserved.
//

#import "ColorSlider.h"
#import "PureLayout.h"

@implementation ColorSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sliderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorSlider"]];
        [self addSubview:_sliderImageView];
        [_sliderImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_sliderImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [_sliderImageView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [_sliderImageView autoSetDimension:ALDimensionHeight toSize:2.0];
        _thumbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_thumbButton setBackgroundImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
        _thumbButton.bounds = CGRectMake(0, 0, 31, 31);
        [self addSubview:_thumbButton];
        [_thumbButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_thumbButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:-2];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderAction:)];
        [_thumbButton addGestureRecognizer:panGesture];
     }
    return self;
}

- (void)sliderAction:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self];
    point.y = self.bounds.size.height/2;
    if (point.x < 14) {
        point.x = 14;
    }
    if (point.x > self.bounds.size.width - 14) {
        point.x = self.bounds.size.width - 14;
    }
    _thumbButton.center = point;
    self.myValue = (floorf(((point.x-14)/(self.bounds.size.width - 27.5))*100+0.5))/100;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorSliderValueChanged:withState:)]) {
        [self.delegate colorSliderValueChanged:self.myValue withState:sender.state];
    }
}

- (void)sliderMyValue:(CGFloat)hue {
    self.myValue = hue;
    CGFloat x = hue * (self.bounds.size.width - 28.0) + 14;
    [UIView animateWithDuration:0.2 animations:^{
        _thumbButton.center = CGPointMake(x, self.bounds.size.height/2);
    }];
}


@end
