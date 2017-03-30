//
//  XZMGradientProgressView.m
//  LayerDemo
//
//  Created by CHT-Technology on 2017/3/22.
//  Copyright © 2017年 CHT-Technology. All rights reserved.
//

#import "XZMGradientProgressView.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0]
#define Height(view) view.frame.size.height
#define Width(view) view.frame.size.width
#define Left(view) view.frame.origin.x
#define Top(view) view.frame.origin.y
#define ProgressH MIN(10, Height(self)) //进度条高度
static const CGFloat TitleLabelH = 18; //数字高度
static const CGFloat TitleLabelW = 40; //数字宽度
static const CGFloat AnimationTime = 1.f; //动画时间

@interface XZMGradientProgressView (){
    
    XZMGradientProgressStyle _style;
    BOOL _showTitle;
    BOOL _animation;
    CGFloat _titlePrecent;
    NSTimer *_timer;
    
}

@property (nonatomic,strong)CAShapeLayer *bgLayer;
@property (nonatomic,strong)CAShapeLayer *maskLayer;
@property (nonatomic,strong)CAGradientLayer *gradientLayer;
@property (nonatomic,strong)CAGradientLayer *gradientTitleLayer;
@property (nonatomic,strong)UILabel *titleLabel;

@end

@implementation XZMGradientProgressView

+(instancetype)gradientProgressViewWithFrame:(CGRect)frame
                                       style:(XZMGradientProgressStyle)style
                                   showTitle:(BOOL)showTitle
                                   animation:(BOOL)animation{
    
    XZMGradientProgressView *progressView = [[XZMGradientProgressView alloc]initWithFrame:frame];
    if(Height(progressView) > TitleLabelH + 10)
        progressView ->_style = style;
    
    progressView ->_showTitle = showTitle;
    progressView ->_animation = animation;
    progressView.gradientCGColors = @[(id)[UIColor greenColor].CGColor,
                                      (id)[UIColor yellowColor].CGColor,
                                      (id)[UIColor orangeColor].CGColor,
                                      (id)[UIColor redColor].CGColor];
    progressView.progress = 0;
    
    [progressView setup];
    return progressView;
    
}

#pragma mark -- Private Methods
- (void)setup{
    
    [self.layer addSublayer:self.bgLayer];
    [self.layer addSublayer:self.gradientLayer];
    if (_showTitle) {
        if (_style == XZMGradientProgressStyleLine) {
            [self.layer addSublayer:self.gradientTitleLayer];
        }else{
            [self addSubview:self.titleLabel];
            self.titleLabel.center = CGPointMake(Width(self)/2.f, Height(self)/2.f);
        }
    }
}

- (void)changeTitleText{
    
    if (!self.progress) [self revokeTimer];
    
    _titlePrecent += _progress*100.f/(AnimationTime/0.1f);
    if (_titlePrecent > _progress*100) {
        [self revokeTimer];
        _titlePrecent = _progress*100;
    }
    self.titleLabel.text = [NSString stringWithFormat:@"%.0f%%",_titlePrecent];
    
}


#pragma mark -- Lazzy
- (CAShapeLayer *)bgLayer{
    
    if(!_bgLayer){
        _bgLayer = [CAShapeLayer layer];
        _bgLayer.lineWidth = ProgressH;
        _bgLayer.strokeColor = RGB(243, 243, 243).CGColor;
        _bgLayer.fillColor = [UIColor clearColor].CGColor;
        _bgLayer.lineCap = kCALineCapRound;
        UIBezierPath *path = [UIBezierPath bezierPath];
        if (_style == XZMGradientProgressStyleLine) {
            CGFloat topSpace = _showTitle?TitleLabelH:(Height(self) - ProgressH)/2.f;
            [path moveToPoint:CGPointMake(ProgressH/2.f, topSpace + ProgressH/2.f)];
            [path addLineToPoint:CGPointMake(Width(self) - ProgressH/2.f, topSpace + ProgressH/2.f)];
        }else{
            [path addArcWithCenter:CGPointMake(Width(self)/2.f, Height(self)/2.f) radius:(MIN(Width(self), Height(self)) - ProgressH)/2.f startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        }
        _bgLayer.path = [path CGPath];
    }
    return _bgLayer;
}

- (CAShapeLayer *)maskLayer{
    
    if(!_maskLayer){
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.lineWidth = ProgressH;
        _maskLayer.strokeColor = [UIColor redColor].CGColor;
        _maskLayer.lineCap = kCALineCapRound;
        UIBezierPath *path = [UIBezierPath bezierPath];
        if (_style == XZMGradientProgressStyleLine) {
            [path moveToPoint:CGPointMake(0, ProgressH/2.f)];
            [path addLineToPoint:CGPointMake(Width(_gradientLayer), ProgressH/2.f)];
        }else{
            [path addArcWithCenter:CGPointMake(Width(_gradientLayer)/2.f, Height(_gradientLayer)/2.f) radius:(MIN(Width(self), Height(self)) - ProgressH)/2.f startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        }
        _maskLayer.path = [path CGPath];
        _maskLayer.strokeEnd = 0;
    }
    return _maskLayer;
}

- (CAGradientLayer *)gradientLayer{
    
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        CGRect rect;
        if (_style == XZMGradientProgressStyleLine) {
            rect = CGRectMake(0, _showTitle?TitleLabelH:(Height(self) - ProgressH)/2.f, Width(self), ProgressH);
        }else{
            CGFloat width = MIN(Width(self), Height(self));
            rect = CGRectMake((Width(self)-width)/2.f, (Height(self)-width)/2.f, width, width);
        }
        _gradientLayer.frame = rect;
        _gradientLayer.cornerRadius = Height(_gradientLayer)/2.f;
        _gradientLayer.masksToBounds = YES;
        _gradientLayer.colors = self.gradientCGColors;
        _gradientLayer.locations = [self getLocations];
        _gradientLayer.startPoint = CGPointZero;
        _gradientLayer.endPoint = CGPointMake(1, 0);
        _gradientLayer.mask = self.maskLayer;
    }
    return _gradientLayer;
}

- (CAGradientLayer *)gradientTitleLayer{
    
    if (!_gradientTitleLayer) {
        _gradientTitleLayer = [[CAGradientLayer alloc]init];
        _gradientTitleLayer.frame = CGRectMake(0, 0, Width(self), TitleLabelH);
        _gradientTitleLayer.colors = self.gradientCGColors;
        _gradientTitleLayer.locations = [self getLocations];
        _gradientTitleLayer.startPoint = CGPointZero;
        _gradientTitleLayer.endPoint = CGPointMake(1, 0);
        _gradientTitleLayer.mask = self.titleLabel.layer;
    }
    
    return _gradientTitleLayer;
}

- (UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, TitleLabelW, TitleLabelH)];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = 1;
        _titleLabel.text = @"0%";
    }
    
    return _titleLabel;
}

- (NSArray *)getLocations{
    if (_gradientCGColors.count == 0)
        return nil;
    
    NSMutableArray *locations = [NSMutableArray array];
    CGFloat present = 1.f/_gradientCGColors.count;
    for (int i = 0; i < _gradientCGColors.count; i ++) {
        [locations addObject:@(present*(i+1))];
    }
    return locations;
}


#pragma mark -- Setter
- (void)setGradientCGColors:(NSArray *)gradientCGColors{
    
    _gradientCGColors = gradientCGColors;
    self.gradientLayer.colors = _gradientCGColors;
    self.gradientLayer.locations = [self getLocations];
    if(_showTitle){
        self.gradientTitleLayer.colors = _gradientCGColors;
        self.gradientTitleLayer.locations = self.gradientLayer.locations;
    }
}

- (void)setProgress:(CGFloat)progress{
    
    _progress = progress;
    if(_progress > 1) _progress = 1.f;
    
}


#pragma mark -- Animation
- (CABasicAnimation *)basicAnimationWithKey:(NSString *)key toValue:(NSValue *)toValue{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = AnimationTime;
    animation.repeatCount = 1;
    animation.toValue = toValue;
    //禁止还原
    animation.autoreverses = NO;
    //禁止完成即移除
    animation.removedOnCompletion = NO;
    //让动画保持在最后状态
    animation.fillMode = kCAFillModeForwards;
    
    return animation;
}


#pragma mark -- Publish Methods
- (void)startRendering{
    
    CGFloat centerX = MIN(Width(_gradientLayer)-TitleLabelW/2.f, MAX(Width(_gradientLayer)*_progress, TitleLabelW/2.f)) ;
    if (_animation) {
        if (_showTitle) {
            if(_style == XZMGradientProgressStyleLine)[self.titleLabel.layer addAnimation:[self basicAnimationWithKey:@"position"
                                                                    toValue:[NSValue valueWithCGPoint:CGPointMake(centerX, ProgressH/2.f)]]
                                         forKey:@"position"];
            
            if ( _timer) [self revokeTimer];
            _titlePrecent = 0;
            _timer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeTitleText) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
        }
        
        [self.maskLayer addAnimation:[self basicAnimationWithKey:@"strokeEnd"
                                                         toValue:@(_progress)]
                              forKey:@"strokeEnd"];
        
    }else{
        self.maskLayer.strokeEnd = _progress;
        
        if (_showTitle) {
            if(_style == XZMGradientProgressStyleLine)self.titleLabel.center = CGPointMake(centerX, ProgressH/2.f);
            self.titleLabel.text = [NSString stringWithFormat:@"%.0f%%",_progress*100];
        }
    }
}


#pragma mark -- Recovery
- (void)removeFromSuperview{
    
    @try {
        [self revokeTimer];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    [super removeFromSuperview];
}

- (void)revokeTimer{
    NSLog(@"销毁");
    [_timer invalidate];
    _timer = nil;
}

@end
