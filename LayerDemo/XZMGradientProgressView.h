//
//  XZMGradientProgressView.h
//  LayerDemo
//
//  Created by CHT-Technology on 2017/3/22.
//  Copyright © 2017年 CHT-Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    
    XZMGradientProgressStyleLine,
    XZMGradientProgressStyleCircle,
    
} XZMGradientProgressStyle;

@interface XZMGradientProgressView : UIView

+(instancetype)gradientProgressViewWithFrame:(CGRect)frame
                                          style:(XZMGradientProgressStyle)style
                                      showTitle:(BOOL)showTitle
                                      animation:(BOOL)animation;

@property (nonatomic,assign)CGFloat progress;
@property (nonatomic,strong)NSArray *gradientCGColors;

- (void)startRendering;

@end
