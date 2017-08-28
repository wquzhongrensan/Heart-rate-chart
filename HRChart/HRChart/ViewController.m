//
//  ViewController.m
//  HRChart
//
//  Created by AppsComm on 2017/8/28.
//  Copyright © 2017年 quzhongrensan. All rights reserved.
//

#import "ViewController.h"
#import "LYLineChart.h"
@interface ViewController ()
@property (strong , nonatomic) LYLineChart *lineChart;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view addSubview:self.lineChart];
}

- (LYLineChart *)lineChart{
    if (!_lineChart) {
        NSMutableArray *xArray = [NSMutableArray array];
        NSMutableArray *yArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 25; i++) {
            [xArray addObject:[NSString stringWithFormat:@"%ld",(long)i]];
        }
        _lineChart = [[LYLineChart alloc]initWithFrame:self.view.bounds xTitleArray:xArray yValueArray:yArray yMax:160 yMin:40];
    }
    return _lineChart;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
