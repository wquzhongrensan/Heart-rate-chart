//
//  LYXAxis.m
//  IphoneApp
//
//  Created by AppsComm on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LYXAxis.h"

#define IntervalUTC (28800)
#define Font_Size 10
#define numberOfYAxisElements 4
#define VerticalMargin 20
#define DashHeight 7
#define topMargin 0   //为顶部留出的空白
#define kChartAlertColor     [UIColor redColor]
#define kChartLineColor      [UIColor orangeColor]
#define kChartTextColor      [UIColor grayColor]
#define HINTColor  [UIColor colorWithRed:50/255.0 green:51/255.0 blue:50/255.0 alpha:1]
#define CurLineColor    [UIColor colorWithRed:255/255.0 green:67/255.0 blue:102/255.0 alpha:1]
#define leftMargin 15 //45
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define P_M(x,y) CGPointMake(x, y)


@implementation LYGraphPoint

-(instancetype)initWithTime:(NSString*)time value:(int)value{
    self = [super init];
    if (self) {
        self.time = time;
        self.value = value;
    }
    return self;
}

@end

@interface LYXAxis ()<UIGestureRecognizerDelegate>
{
    NSMutableArray* allPoints;
}
@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSArray *yValueArray;

@property (nonatomic, retain) UILabel *descriptionView;
@property (nonatomic, retain) UIView *slideLineView;

@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;
@property (assign, nonatomic) CGFloat defaultSpace;

/**
 *  记录坐标轴的第一个frame
 */
@property (assign, nonatomic) CGRect firstFrame;
@property (assign, nonatomic) CGRect firstStrFrame;//第一个点的文字的frame

@end



@implementation LYXAxis

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin source:(NSArray *)source{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.xTitleArray = xTitleArray;
        self.yValueArray = yValueArray;
        self.sourceData = source;
        self.yMax = yMax;
        self.yMin = yMin;
        
        _defaultSpace = 30;
        
        self.pointGap = _defaultSpace;
        
         allPoints = [NSMutableArray array];
    }
     return self;
}

- (void)setPointGap:(CGFloat)pointGap {
    _pointGap = pointGap;
    
    [self setNeedsDisplay];
}

- (void)setIsLongPress:(BOOL)isLongPress {
    _isLongPress = isLongPress;
    
    [self setNeedsDisplay];
}

- (CGFloat)xOffset{
    NSArray *sortedPts = [self.sourceData sortedArrayUsingComparator:^NSComparisonResult(LYGraphPoint *p1, LYGraphPoint *p2){
        return [p1.time compare:p2.time];
    }];
    LYGraphPoint *firstPoint =  [sortedPts firstObject];
    CGFloat xO = [self xWithKey:firstPoint];
    return xO;
}

- (void)reloadData{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 添加坐标轴Label
    for (int i = 0; i < self.xTitleArray.count; i++) {
        NSString *title = self.xTitleArray[i];
        
        [[UIColor blackColor] set];
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
        CGSize labelSize = [title sizeWithAttributes:attr];
        //+ 1
        
        CGRect titleRect = CGRectMake((i ) * self.pointGap - labelSize.width / 2+leftMargin,self.frame.size.height - labelSize.height/2-BottomHeight/2,labelSize.width,labelSize.height);
        
        if (i == 0) {
            self.firstFrame = titleRect;
            if (titleRect.origin.x < 0) {
                titleRect.origin.x = 0;
            }
            
            [title drawInRect:titleRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];
            
        }
        // 如果Label的文字有重叠，那么不绘制
        CGFloat maxX = CGRectGetMaxX(self.firstFrame);
        if (i != 0) {
            if ((maxX + 3) > titleRect.origin.x) {
                //不绘制
                
            }else{
                
                [title drawInRect:titleRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];
                
                self.firstFrame = titleRect;
            }
        }else {
            if (self.firstFrame.origin.x < 0) {
                
                CGRect frame = self.firstFrame;
                frame.origin.x = 0;
                self.firstFrame = frame;
            }
        }
     }
    
    NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
    CGSize textSize = [@"x" sizeWithAttributes:attribute];
    CGFloat topPointY = 0, bottonPointY = 0;
    
    //横向画线
    for (int i = 0; i < numberOfYAxisElements+1; i++) {
        CGFloat labelMargin = (self.frame.size.height - BottomHeight - VerticalMargin*2 - (numberOfYAxisElements + 1) * textSize.height) / numberOfYAxisElements;
        [self drawLine:context
            startPoint:CGPointMake(0, self.frame.size.height - BottomHeight- VerticalMargin - labelMargin* i - textSize.height*(i+1)+textSize.height/2)
              endPoint:CGPointMake(0+self.frame.size.width, self.frame.size.height - BottomHeight- VerticalMargin - labelMargin* i - textSize.height*(i+1)+textSize.height/2)
             lineColor:[UIColor lightGrayColor]
             lineWidth:.2
                  dash:YES];
        if (i == 0) {
            bottonPointY = self.frame.size.height - BottomHeight- VerticalMargin - labelMargin* i - textSize.height*(i+1)+textSize.height/2;
        }else if (i == numberOfYAxisElements){
            topPointY = self.frame.size.height - BottomHeight- VerticalMargin - labelMargin* i - (textSize.height*(i+1))+textSize.height/2;

        }
    }
    CGFloat chartHeight =bottonPointY -  topPointY;
   
    [self drawPointAndLine:context bottomY:bottonPointY chartHeight:chartHeight];
    
    //长按 状态下的操作
    if(self.isLongPress)
    {
        NSUInteger selectIndex;
        selectIndex = [self closestDotFromtouchPoint:_currentLoc];
        if(selectIndex < [self.sourceData count]) {
            LYGraphPoint *num;
            CGPoint selectPoint;
            
            selectPoint = [[allPoints objectAtIndex:selectIndex] CGPointValue];
            num= [self.sourceData objectAtIndex:selectIndex];
           
            NSDictionary *timeAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
            CGSize timeSize = [[NSString stringWithFormat:@"%@",num.time] sizeWithAttributes:timeAttr];
            
            //画文字所在的位置  动态变化
            CGPoint drawPoint = CGPointZero;
            if(_screenLoc.x >((kScreenWidth-leftMargin)/2) && _screenLoc.y < 80) {
                //如果按住的位置在屏幕靠右边边并且在屏幕靠上面的地方   那么字就显示在按住位置的左上角40 60位置
                drawPoint = CGPointMake(_currentLoc.x-40-timeSize.width, 80-60);
            }
            else if(_screenLoc.x >((kScreenWidth-leftMargin)/2) && _screenLoc.y > self.frame.size.height-20) {
                drawPoint = CGPointMake(_currentLoc.x-40-timeSize.width, self.frame.size.height-20 -60);
            }
            else if(_screenLoc.x >((kScreenWidth-leftMargin)/2)) {
                //如果按住的位置在屏幕靠右边边   那么字就显示在按住位置的左上角40 60位置
                drawPoint = CGPointMake(_currentLoc.x-40-timeSize.width, _currentLoc.y-60);
            }
            else if (_screenLoc.x <= ((kScreenWidth-leftMargin)/2) && _screenLoc.y < 80) {
                //如果按住的位置在屏幕靠左边边并且在屏幕靠上面的地方   那么字就显示在按住位置的右上角上角40 40位置
                drawPoint = CGPointMake(_currentLoc.x+40, 80-60);
                
            }
            else if (_screenLoc.x <= ((kScreenWidth-leftMargin)/2) && _screenLoc.y > self.frame.size.height-20) {
                
                drawPoint = CGPointMake(_currentLoc.x+40, self.frame.size.height-20 -60);
                
            }
            else if(_screenLoc.x  <= ((kScreenWidth-leftMargin)/2)) {
                //如果按住的位置在屏幕靠左边   那么字就显示在按住位置的右上角40 60位置
                drawPoint = CGPointMake(_currentLoc.x+40, _currentLoc.y-60);
            }
            //画选中的数值
            [[NSString stringWithFormat:@"%@",num.time] drawAtPoint:CGPointMake(drawPoint.x, drawPoint.y) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:HINTColor}];
            
            
           [[NSString stringWithFormat:@"%d %@",(int)num.value,@"Frequency"] drawAtPoint:CGPointMake(drawPoint.x, drawPoint.y+15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:HINTColor}];
            
         
            [self drawLine:context startPoint:CGPointMake(selectPoint.x, 0) endPoint:CGPointMake(selectPoint.x, self.frame.size.height- BottomHeight) lineColor:HINTColor lineWidth:1 dash:YES];
            
            //交界点
            CGRect myOval = {selectPoint.x-2, selectPoint.y-2, 4, 4};
            CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
            CGContextAddEllipseInRect(context, myOval);
            CGContextFillPath(context);
        }
    }
}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width dash:(BOOL)isDash{
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    if (isDash) {
        CGFloat lengths[] = {5,2};
        CGContextSetLineDash(context,0,lengths,2);
    }
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);

}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width{
    [self drawLine:context startPoint:startPoint endPoint:endPoint lineColor:lineColor lineWidth:width dash:NO];
}

/*动画画图 目前还不完善 暂时不用*/
- (void)drawCurLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width{
    CGPoint control1;
    CGPoint control2;
    
    /*control1 = P_M(endPoint.x + (startPoint.x - endPoint.x) / 2.0, startPoint.y );
    control2 = P_M(endPoint.x + (startPoint.x - endPoint.x) / 2.0, endPoint.y);*/
    
    
    CGFloat deltaX = endPoint.x - startPoint.x;
    
    if (deltaX*2 > self.height) {
        deltaX/=2;
        DBLog(@"delta 减半");
    }
    
    control1 = CGPointMake((endPoint.x+startPoint.x)/2, startPoint.y-deltaX);
    control2 = CGPointMake((endPoint.x+startPoint.x)/2, endPoint.y+deltaX);
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddCurveToPoint(context, control1.x, control1.y, control2.x, control2.y, endPoint.x, endPoint.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace);
}

//带动画效果
- (void)drawLine:(CGContextRef)context lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width{
    
    CAShapeLayer *lineLayer;
    lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = lineColor.CGColor;
    lineLayer.backgroundColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = width;
    [self.layer addSublayer:lineLayer];
    
    UIBezierPath *linePath;
    linePath = [UIBezierPath bezierPath];
    
    NSArray *sortedPts = [self.sourceData sortedArrayUsingComparator:^NSComparisonResult(LYGraphPoint *p1, LYGraphPoint *p2){
        return [p1.time compare:p2.time];
    }];
    self.sourceData = sortedPts;
    //清空上一次的x/y坐标点
    [allPoints removeAllObjects];
    CGFloat topPointY = 0, bottonPointY = 0;
    CGFloat chartHeight =bottonPointY -  topPointY;
    //数据点与连线
    if (sortedPts && sortedPts.count > 0) {
        //画折线
        for (NSInteger i = 0; i < sortedPts.count; i++) {
            //如果是最后一个点
            if (i == sortedPts.count-1) {
                
                LYGraphPoint *endValue = sortedPts[i];
                //CGFloat chartHeight =bottonPointY -  topPointY;
                //+1
                CGPoint endPoint = CGPointMake([self xWithKey:endValue], bottonPointY -  (endValue.value-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
                
                [allPoints addObject:[NSValue valueWithCGPoint:endPoint]];
                
                //画最后一个点
                UIColor *aColor = UIColorFromHex(0x63B8FF); //点的颜色
                CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
                CGContextAddArc(context, endPoint.x, endPoint.y, 1, 0, 2*M_PI, 0); //添加一个圆
                CGContextDrawPath(context, kCGPathFill);//绘制填充
                //画点上的文字
                NSString *str = [NSString stringWithFormat:@"%.2ld", (long)endValue.value];
                // 判断是不是小数
                if ([self isPureFloat:endValue.value]) {
                    str = [NSString stringWithFormat:@"%.2ld", (long)endValue.value];
                }
                else {
                    str = [NSString stringWithFormat:@"%.0ld", (long)endValue.value];
                }
                
                NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
                CGSize strSize = [str sizeWithAttributes:attr];
                CGRect strRect = CGRectMake(endPoint.x-strSize.width/2,endPoint.y-strSize.height,strSize.width,strSize.height);
                // 如果点的文字有重叠，那么不绘制
                CGFloat maxX = CGRectGetMaxX(self.firstStrFrame);
                if (i != 0) {
                    if ((maxX + 3) > strRect.origin.x) {
                        //不绘制
                        
                    }else{
                        
                        [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];
                        
                        self.firstStrFrame = strRect;
                    }
                }else {
                    if (self.firstStrFrame.origin.x < 0) {
                        
                        CGRect frame = self.firstStrFrame;
                        frame.origin.x = 0;
                        self.firstStrFrame = frame;
                    }
                }
                
            }else {
                
                LYGraphPoint *startValue = sortedPts[i];
                LYGraphPoint *endValue = sortedPts[i+1];
                //CGFloat chartHeight =bottonPointY -  topPointY;
                //+1 +2
                CGPoint startPoint = CGPointMake([self xWithKey:startValue], bottonPointY -  (startValue.value-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
                CGPoint endPoint = CGPointMake([self xWithKey:endValue], bottonPointY -  (endValue.value-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
                
                [allPoints addObject:[NSValue valueWithCGPoint:startPoint]];
                
                CGFloat normal[1]={1};
                CGContextSetLineDash(context,0,normal,0); //画实线
               
                CGPoint control1 = P_M(endPoint.x + (startPoint.x - endPoint.x) / 2.0, startPoint.y );
                CGPoint control2 = P_M(endPoint.x + (startPoint.x - endPoint.x) / 2.0, endPoint.y);
                
                if (i == 0) {
                    [linePath moveToPoint:startPoint];
                }else{
                [linePath addCurveToPoint:endPoint controlPoint1:control1 controlPoint2:control2];
                }
                
                
                //画点[UIColor redColor]
                UIColor *aColor = [UIColor redColor]; //点的颜色
                CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
                CGContextAddArc(context, startPoint.x, startPoint.y, 1, 0, 2*M_PI, 0); //添加一个圆
                CGContextDrawPath(context, kCGPathFill);//绘制填充
                
                if (!_isShowLabel) {
                    //画点上的文字
                    NSString *str = [NSString stringWithFormat:@"%.2ld", (long)endValue.value];
                    // 判断是不是小数
                    if ([self isPureFloat:startValue.value]) {
                        str = [NSString stringWithFormat:@"%.2ld", (long)startValue.value];
                    }
                    else {
                        str = [NSString stringWithFormat:@"%.0ld", (long)startValue.value];
                    }
                    
                    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font_Size]};
                    CGSize strSize = [str sizeWithAttributes:attr];
                    
                    CGRect strRect = CGRectMake(startPoint.x-strSize.width/2,startPoint.y-strSize.height,strSize.width,strSize.height);
                    if (i == 0) {
                        self.firstStrFrame = strRect;
                        if (strRect.origin.x < 0) {
                            strRect.origin.x = 0;
                        }
                        
                        [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];
                    }
                    // 如果点的文字有重叠，那么不绘制
                    CGFloat maxX = CGRectGetMaxX(self.firstStrFrame);
                    //CGFloat maxY = CGRectGetMaxY(strRect);
                    if (i != 0) {
                        //if ((maxX + 3) > strRect.origin.x && (CGRectContainsPoint(self.firstStrFrame, strRect.origin) || CGRectContainsPoint(self.firstStrFrame, P_M(strRect.origin.x, maxY) )))
                        if ((maxX + 3) > strRect.origin.x) {
                            //不绘制
                        }else{
                            //,NSBackgroundColorAttributeName:[UIColor blackColor]
                            [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:Font_Size],NSForegroundColorAttributeName:kChartTextColor}];
                            
                            self.firstStrFrame = strRect;
                        }
                    }else {
                        if (self.firstStrFrame.origin.x < 0) {
                            
                            CGRect frame = self.firstStrFrame;
                            frame.origin.x = 0;
                            self.firstStrFrame = frame;
                        }
                    }
                }
            }
        }
    }

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 2;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    [lineLayer addAnimation:animation forKey:@"strokeEnd"];
}

#pragma mark  --- 描点和连线
- (void)drawPointAndLine:(CGContextRef)context bottomY:(CGFloat)bottonPointY chartHeight:(CGFloat)chartHeight{
    NSArray *sortedPts = [self.sourceData sortedArrayUsingComparator:^NSComparisonResult(LYGraphPoint *p1, LYGraphPoint *p2){
     return [p1.time compare:p2.time];
     }];
     self.sourceData = sortedPts;
     //清空上一次的x/y坐标点
     [allPoints removeAllObjects];
     //数据点与连线
     if (sortedPts && sortedPts.count > 0) {
     
     //画折线
     for (NSInteger i = 0; i < sortedPts.count; i++) {
     //如果是最后一个点
     if (i == sortedPts.count-1) {
     
     LYGraphPoint *endValue = sortedPts[i];
     
     CGPoint endPoint = CGPointMake([self xWithKey:endValue], bottonPointY -  (endValue.value-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
     
     [allPoints addObject:[NSValue valueWithCGPoint:endPoint]];
     
     //画最后一个点
     UIColor *aColor = CurLineColor; //点的颜色
     CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
     CGContextAddArc(context, endPoint.x, endPoint.y, 1, 0, 2*M_PI, 0); //添加一个圆
     CGContextDrawPath(context, kCGPathFill);//绘制填充
         
     }else {
     
     LYGraphPoint *startValue = sortedPts[i];
     LYGraphPoint *endValue = sortedPts[i+1];
     //CGFloat chartHeight =bottonPointY -  topPointY;
     //+1 +2
     CGPoint startPoint = CGPointMake([self xWithKey:startValue], bottonPointY -  (startValue.value-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
     CGPoint endPoint = CGPointMake([self xWithKey:endValue], bottonPointY -  (endValue.value-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
     
     [allPoints addObject:[NSValue valueWithCGPoint:startPoint]];
     
     CGFloat normal[1]={1};
     CGContextSetLineDash(context,0,normal,0); //画实线
     [self drawCurLine:context startPoint:startPoint endPoint:endPoint lineColor:CurLineColor lineWidth:1.4];
     
    //画点UIColorFromHex(0x63B8FF)
     UIColor *aColor = CurLineColor; //点的颜色
     CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
     CGContextAddArc(context, startPoint.x, startPoint.y, 0.7, 0, 2*M_PI, 0); //添加一个圆
     CGContextDrawPath(context, kCGPathFill);//绘制填充
        }
     }
     }

}

#pragma mark  --- utils
// 判断是小数还是整数
- (BOOL)isPureFloat:(CGFloat)num {
    int i = num;
    CGFloat result = num - i;
    // 当不等于0时，是小数
    return result != 0;
}

- (CGFloat)xWithKey:(LYGraphPoint*)keyPair{
    if (!keyPair) {
        return 0;
    }
    CGFloat x;
    NSDate* date = [self dateFromString:keyPair.time format:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:IntervalUTC sinceDate:date];
    //求出这个时间点是当天的第几秒
    int delta = [destinationDateNow sencondsInDaysWithUTC];
    CGFloat partion =  delta/(86400*1.0);
    x = ((self.xTitleArray.count-1)*self.pointGap)*partion+leftMargin;
    return x;
}


- (NSUInteger)closestDotFromtouchPoint:(CGPoint)touchPoint {
    __block NSInteger currentlyCloser = 1000;
    __block NSInteger closePIndex;
    
    [allPoints enumerateObjectsUsingBlock:^(NSValue  *_Nonnull point, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if (pow((([point CGPointValue].x) - touchPoint.x), 2) < currentlyCloser) {
            currentlyCloser = pow((([point CGPointValue].x) - touchPoint.x), 2);
            closePIndex = idx;
        }
    }];
    return closePIndex;
}

- (NSInteger)indexFromPoint:(CGFloat)centerX{
    
    return 0;
}

- (NSDate *)dateFromString:(NSString *)timeStr
                    format:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    return date;
}

@end
