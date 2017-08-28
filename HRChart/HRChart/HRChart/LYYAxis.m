//
//  LYYAxis.m
//  IphoneApp
//
//  Created by AppsComm on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LYYAxis.h"

#define xAxisTextGap 5 //x轴文字与坐标轴间隙
#define numberOfYAxisElements 4 // y轴分为几段
#define kChartLineColor         [UIColor grayColor]
#define kChartTextColor         [UIColor grayColor]
#define TextBC  [UIColor blackColor]
#define VerticalMargin 20
#define Font_Size 10

@interface LYYAxis ()

@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;

@end

@implementation LYYAxis

- (id)initWithFrame:(CGRect)frame yMax:(CGFloat)yMax yMin:(CGFloat)yMin {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.yMax = yMax;
        self.yMin = yMin;
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
    // 计算坐标轴的位置以及大小
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
    
    CGSize labelSize = [@"x" sizeWithAttributes:attr];
    
    NSDictionary *waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
    
    
    // Label做占据的高度
    CGFloat allLabelHeight = self.frame.size.height;
    // Label之间的间隙
    CGFloat labelMargin = (allLabelHeight - VerticalMargin*2 - (numberOfYAxisElements + 1) * labelSize.height) / numberOfYAxisElements;
    
    // 添加Label
    for (int i = 0; i < numberOfYAxisElements + 1; i++) {
        
        CGFloat avgValue = (self.yMax - self.yMin) / numberOfYAxisElements;
        
        // 判断是不是小数
        if ([self isPureFloat:self.yMin + avgValue * i]) {
            CGSize yLabelSize = [[NSString stringWithFormat:@"%.2f", self.yMin + avgValue * i] sizeWithAttributes:waterAttr];
            
            [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i] drawInRect:CGRectMake(self.frame.size.width-yLabelSize.width-xAxisTextGap, self.frame.size.height- VerticalMargin - labelMargin* i - yLabelSize.height*(i+1), yLabelSize.width, yLabelSize.height) withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];
        }
        else {
            CGSize yLabelSize = [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i] sizeWithAttributes:waterAttr];
            [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i] drawInRect:CGRectMake(self.frame.size.width-yLabelSize.width-xAxisTextGap, self.frame.size.height- VerticalMargin - labelMargin* i - yLabelSize.height*(i+1), yLabelSize.width, yLabelSize.height) withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];//,NSBackgroundColorAttributeName:TextBC
        }
        
    }
}

// 判断是小数还是整数
- (BOOL)isPureFloat:(CGFloat)num
{
    int i = num;
    
    CGFloat result = num - i;
    
    // 当不等于0时，是小数
    return result != 0;
}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);
}


@end
