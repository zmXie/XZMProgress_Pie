//
//  XZMPieView.m
//  LayerDemo
//
//  Created by CHT-Technology on 2017/3/24.
//  Copyright © 2017年 CHT-Technology. All rights reserved.
//

#import "XZMPieView.h"

@interface XZMLayer : CAShapeLayer

@property (nonatomic,assign)CGFloat startAngle;
@property (nonatomic,assign)CGFloat endAngle;
@property (nonatomic,assign)BOOL    isSelected;

@end

@implementation XZMLayer


@end

#define kPieRandColor [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:1.0f]

#define Hollow_Circle_Radius 0 //中间空心圆半径，默认为0实心
#define KOffsetRadius 10 //偏移距离
#define KMargin 20 //边缘间距

@interface XZMPieView (){
    
    CAShapeLayer *_maskLayer;
    CGFloat _radius;
    CGPoint _center;
    
}

@end

@implementation XZMPieView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //线的半径为扇形半径的一半，线宽是扇形半径->半径+线宽的一半=真实半径，这样就能画出圆形了
        _radius = (frame.size.width - KMargin*2)/4.f;
        _center = CGPointMake(_radius*2 + KMargin, _radius*2 + KMargin);
        _sectorSpace = 0;
        //通过mask来控制显示区域
        _maskLayer = [CAShapeLayer layer];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:_center radius:self.bounds.size.width/4.f startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
        //设置边框颜色为不透明，则可以通过边框的绘制来显示整个view
        _maskLayer.strokeColor = [UIColor greenColor].CGColor;
        _maskLayer.lineWidth = self.bounds.size.width/2.f;
        //设置填充颜色为透明，可以通过设置半径来设置中心透明范围
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.path = maskPath.CGPath;
        _maskLayer.strokeEnd = 0;
        self.layer.mask = _maskLayer;
        
    }
    
    return self;
}

#pragma mark -- Publish Methods
- (void)setDatas:(NSArray <NSNumber *>*)datas
          colors:(NSArray <UIColor *>*)colors{
    
    NSArray *newDatas = [self getPersentArraysWithDataArray:datas];
    
    /*
     //方法一：每个layer公用一个圆形path，通过数据比例来控制strokeStart，strokeEnd，从而绘制对应区域；优点：性能相对较好；缺点：不容易通过touch来获取相应的layer。
     UIBezierPath *piePath = [UIBezierPath bezierPathWithArcCenter:_center radius:_radius + Hollow_Circle_Radius startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
     CGFloat start = 0.f;
     CGFloat end = 0.f;
     for (NSNumber *number in array) {
     
     end =  start + number.floatValue;
     CAShapeLayer *pieLayer = [CAShapeLayer layer];
     pieLayer.strokeStart = start;
     pieLayer.strokeEnd = end;
     pieLayer.lineWidth = _radius*2 - Hollow_Circle_Radius;
     pieLayer.strokeColor = kPieRandColor.CGColor;
     pieLayer.fillColor = [UIColor clearColor].CGColor;
     pieLayer.path = piePath.CGPath;
     
     [self.layer addSublayer:pieLayer];
     start = end;
     }
     */
    
    //方法二:每个layer对应一个path，通过数据比例来计算起始角点跟结束角点；相对第一种方法，创建的path较多；但是可以通过path来找到对应的layer，方便做后期操作
    CGFloat start = -M_PI_2;
    CGFloat end = start;
    
    while (newDatas.count > self.layer.sublayers.count) {
        
        XZMLayer *pieLayer = [XZMLayer layer];
        pieLayer.strokeColor = NULL;
        [self.layer addSublayer:pieLayer];
    }
    _sectorSpace = newDatas.count < 3 ? 0 : _sectorSpace;
    for (int i = 0; i < self.layer.sublayers.count; i ++) {
        
        XZMLayer *pieLayer = (XZMLayer *)self.layer.sublayers[i];
        if (i < newDatas.count) {
            pieLayer.hidden = NO;
            end =  start + (M_PI*2 - _sectorSpace*newDatas.count) *[newDatas[i] floatValue];
            
            UIBezierPath *piePath = [UIBezierPath bezierPath];
            [piePath moveToPoint:_center];
            [piePath addArcWithCenter:_center radius:_radius*2 startAngle:start endAngle:end clockwise:YES];
            
            pieLayer.fillColor = [colors.count > i?colors[i]:kPieRandColor CGColor];
            pieLayer.startAngle = start;
            pieLayer.endAngle = end;
            pieLayer.path = piePath.CGPath;
            
            start = end + _sectorSpace;
        }else{
            pieLayer.hidden = YES;
        }
    }
}

- (void)stroke{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1.f;
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat:1.f];
    //禁止还原
    animation.autoreverses = NO;
    //禁止完成即移除
    animation.removedOnCompletion = NO;
    //让动画保持在最后状态
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_maskLayer addAnimation:animation forKey:@"strokeEnd"];
}

#pragma mark -- Privite Methods
- (NSArray *)getPersentArraysWithDataArray:(NSArray *)datas{
    
    NSArray *newDatas = [datas sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return NSOrderedDescending;
        }else if ([obj1 floatValue] > [obj2 floatValue]){
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
    
    NSMutableArray *persentArray = [NSMutableArray array];
    NSNumber *sum = [newDatas valueForKeyPath:@"@sum.floatValue"];
    for (NSNumber *number in newDatas) {
        [persentArray addObject:@(number.floatValue/sum.floatValue)];
    }
    
    return persentArray;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [touches.anyObject locationInView:self];
    
    [self upDateLayersWithPoint:point];
    
    NSLog(@"%@",NSStringFromCGPoint(point));
}

- (void)upDateLayersWithPoint:(CGPoint)point{
    
    //如需做点击效果，则应采用第二种方法较好
    for (XZMLayer *layer in self.layer.sublayers) {
        
        if (CGPathContainsPoint(layer.path, &CGAffineTransformIdentity, point, 0) && !layer.isSelected) {
            layer.isSelected = YES;
            
            //原始中心点为（0，0），扇形所在圆心、原始中心点、偏移点三者是在一条直线，通过三角函数即可得到偏移点的对应x，y。
            CGPoint currPos = layer.position;
            double middleAngle = (layer.startAngle + layer.endAngle)/2.0;
            CGPoint newPos = CGPointMake(currPos.x + KOffsetRadius*cos(middleAngle), currPos.y + KOffsetRadius*sin(middleAngle));
            layer.position = newPos;
            
        }else{
            
            layer.position = CGPointMake(0, 0);
            layer.isSelected = NO;
        }
    }
}

@end


