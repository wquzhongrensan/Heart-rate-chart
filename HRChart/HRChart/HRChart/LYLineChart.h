//
//  LYLineChart.h
//  IphoneApp
//
//  Created by AppsComm on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYXAxis.h"

@interface LYLineChart : UIView

@property (nonatomic,strong)NSArray *sourceData;
@property (nonatomic,assign)NSInteger maxAlertValue;
@property (nonatomic,assign)NSInteger minAlertValue;

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin;

- (void)reloadChart;
@end
