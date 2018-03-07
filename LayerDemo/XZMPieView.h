//
//  XZMPieView.h
//  LayerDemo
//
//  Created by CHT-Technology on 2017/3/24.
//  Copyright © 2017年 CHT-Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZMPieView : UIView

/** 扇形间距，默认为0*/
@property (nonatomic,assign)CGFloat sectorSpace;

//数据源
- (void)setDatas:(NSArray <NSNumber *>*)datas
          colors:(NSArray <UIColor *>*)colors;

- (void)stroke;

@end


