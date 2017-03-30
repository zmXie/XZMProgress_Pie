//
//  ViewController.m
//  LayerDemo
//
//  Created by CHT-Technology on 2017/3/22.
//  Copyright © 2017年 CHT-Technology. All rights reserved.
//

#import "ViewController.h"
#import "XZMGradientProgressView.h"
#import "XZMPieView.h"

@interface ViewController (){
    
    XZMGradientProgressView *progressView1;
    XZMGradientProgressView *progressView2;
    XZMPieView *pieView;
}



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    progressView1 = [XZMGradientProgressView
                                             gradientProgressViewWithFrame:CGRectMake(20, 100, 200, 50)
                                             style:0
                                             showTitle:YES
                                             animation:YES];
    progressView1.gradientCGColors = @[(id)[UIColor grayColor].CGColor,
                                       (id)[UIColor blueColor].CGColor,
                                       (id)[UIColor orangeColor].CGColor,
                                       (id)[UIColor purpleColor].CGColor];
    progressView1.progress = 0.8;
    [self.view addSubview:progressView1];

    
    progressView2 = [XZMGradientProgressView
                    gradientProgressViewWithFrame:CGRectMake(20, 150, 120, 200)
                    style:1
                    showTitle:YES
                    animation:YES];
    progressView2.progress = 0.6;
    [self.view addSubview:progressView2];
    
    
    pieView = [[XZMPieView alloc]initWithFrame:CGRectMake(80, 350, 200, 200)];
    
    [self.view addSubview:pieView];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [pieView setDatas:[self getDatas] colors:@[[UIColor redColor],[UIColor purpleColor]]];
    [pieView stroke];
    
    [progressView1 startRendering];
    
    [progressView2 startRendering];
}

- (NSArray *)getDatas{
    
    int cout = arc4random() % 5;
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < cout+1 ; i++) {
        
        [arr addObject:@(arc4random()%100)];
    }
    
    return arr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
