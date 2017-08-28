//
//  LYLineChart.m
//  IphoneApp
//
//  Created by AppsComm on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LYLineChart.h"
#import "LYYAxis.h"

#define leftMargin 30
#define lastSpace 30

@interface LYLineChart ()
@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSArray *yValueArray;
@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;
@property (strong, nonatomic) LYYAxis *yAxisView;
@property (strong, nonatomic) LYXAxis *xAxisView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat pointGap;
@property (assign, nonatomic) NSInteger centerIndex;
@property (assign, nonatomic) CGFloat defaultSpace;//间距
@property (assign, nonatomic) CGFloat moveDistance;
@end

@implementation LYLineChart

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.xTitleArray = xTitleArray;
        self.yValueArray = yValueArray;
        self.yMax = yMax;
        self.yMin = yMin;
        CGFloat padding ;//= (CGRectGetWidth(frame)-leftMargin*2)/(self.xTitleArray.count-1);
        padding = 30;//60
        self.pointGap = _defaultSpace = padding;
        
        //画y轴
        [self creatYAxisView];
        
        //画x轴
        [self creatXAxisView];
        
        //添加手势
        [self addGesture];
        
        }
    return self;
}

- (void)setMaxAlertValue:(NSInteger)maxAlertValue{
    if (_maxAlertValue != maxAlertValue) {
        _maxAlertValue = maxAlertValue;
        self.xAxisView.maxValue = _maxAlertValue;
    }
}

- (void)setMinAlertValue:(NSInteger)minAlertValue{
    if (_minAlertValue != minAlertValue) {
        _minAlertValue = minAlertValue;
        self.xAxisView.minValue = _minAlertValue;
    }
}

- (void)reloadChart{
    self.xAxisView.sourceData = self.sourceData;
    [self setNeedsDisplay];
    
    [self adjustOffsetWithFirstPoint:self.xAxisView.xOffset];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

    [self.xAxisView reloadData];

}

- (void)creatYAxisView {
    
    self.yAxisView = [[LYYAxis alloc]initWithFrame:CGRectMake(0, 0, leftMargin, self.frame.size.height-BottomHeight) yMax:self.yMax yMin:self.yMin];
    
    [self addSubview:self.yAxisView];
    
}

- (void)creatXAxisView {
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(leftMargin, 0, self.frame.size.width-leftMargin, self.frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = YES;
    //_scrollView.minimumZoomScale = 0.7;
    
    [self addSubview:_scrollView];
    //+3
    self.xAxisView = [[LYXAxis alloc] initWithFrame:CGRectMake(0, 0, (self.xTitleArray.count) * self.pointGap + lastSpace, self.frame.size.height) xTitleArray:self.xTitleArray yValueArray:self.yValueArray yMax:self.yMax yMin:self.yMin source:self.sourceData];
    [_scrollView addSubview:self.xAxisView];
    
    _scrollView.contentSize = self.xAxisView.frame.size;
//    _scrollView.contentOffset = CGPointMake(self.xTitleArray.count* self.pointGap/3, 0);
}

- (void)addGesture{
    // 2. 捏合手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.xAxisView addGestureRecognizer:pinch];
    
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
    [self.xAxisView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap_Action:)];
    tap.numberOfTapsRequired = 2;
    [self.xAxisView addGestureRecognizer:tap];

}

// 捏合手势监听方法
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //-lastSpace
        //小于屏幕的宽度
        if (self.xAxisView.frame.size.width <= self.scrollView.frame.size.width) {
            //当缩小到小于屏幕宽时，松开回复屏幕宽度
            CGFloat scale = self.scrollView.frame.size.width / (self.xAxisView.frame.size.width-lastSpace);
            self.pointGap *= scale;
             [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = self.xAxisView.frame;
                frame.size.width = self.scrollView.frame.size.width+lastSpace;
                self.xAxisView.frame = frame;
            }];
            self.xAxisView.pointGap = self.pointGap;
            
        }else if (self.xAxisView.frame.size.width >= self.xTitleArray.count * _defaultSpace*2){
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = self.xAxisView.frame;
                frame.size.width = self.xTitleArray.count * _defaultSpace*2;
                self.xAxisView.frame = frame;
                }];
            self.pointGap = _defaultSpace;
            self.xAxisView.pointGap = self.pointGap;
        }
        _centerIndex = 0;
    }else if(recognizer.state == UIGestureRecognizerStateBegan){
        CGPoint p1 = [recognizer locationOfTouch:0 inView:self.xAxisView];
        CGPoint p2 = [recognizer locationOfTouch:1 inView:self.xAxisView];
        CGFloat centerX = (p1.x+p2.x)/2;
        NSInteger index = centerX/self.pointGap;
        _centerIndex = index;
    }else{
            CGFloat leftMagin;
        if( recognizer.numberOfTouches == 2) {
            //2.获取捏合中心点 -> 捏合中心点距离scrollviewcontent左侧的距离
            CGPoint p1 = [recognizer locationOfTouch:0 inView:self.xAxisView];
            CGPoint p2 = [recognizer locationOfTouch:1 inView:self.xAxisView];
            CGFloat centerX = (p1.x+p2.x)/2;
            
            leftMagin = centerX - self.scrollView.contentOffset.x;
            self.pointGap *= recognizer.scale;
            self.pointGap = self.pointGap > _defaultSpace*2 ? _defaultSpace*2 : self.pointGap;
            if(self.pointGap >= _defaultSpace*2){
                return;
            }
            self.xAxisView.pointGap = self.pointGap;
            self.xAxisView.frame = CGRectMake(0, 0, self.xTitleArray.count * self.pointGap + lastSpace, self.frame.size.height);
           self.scrollView.contentOffset = CGPointMake(_centerIndex*self.pointGap - leftMagin , 0);
            //currentIndex*self.pointGap-leftMagin
         }
     }
    self.scrollView.contentSize = CGSizeMake(self.xAxisView.frame.size.width, CGRectGetHeight(self.xAxisView.frame));
}

- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        
        CGPoint location = [longPress locationInView:self.xAxisView];
        
        //相对于屏幕的位置
        CGPoint screenLoc = CGPointMake(location.x - self.scrollView.contentOffset.x, location.y);
        [self.xAxisView setScreenLoc:screenLoc];
        if (YES ||  ABS(location.x - _moveDistance) > self.pointGap) { //不能长按移动一点点就重新绘图  要让定位的点改变了再重新绘图
             [self.xAxisView setIsShowLabel:YES];
            [self.xAxisView setIsLongPress:YES];
            self.xAxisView.currentLoc = location;
            _moveDistance = location.x;
        }
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded)
    {
        //恢复scrollView的滑动
        [self.xAxisView setIsLongPress:NO];
        [self.xAxisView setIsShowLabel:NO];
        
    }
}

- (void)tap_Action:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self.xAxisView];
    NSInteger index = location.x/self.pointGap;
    CGFloat leftMagin = location.x - self.scrollView.contentOffset.x;
    if (self.pointGap >= _defaultSpace*2) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.xAxisView.frame;
            frame.size.width = self.xTitleArray.count * _defaultSpace;
            self.xAxisView.frame = frame;
        }];
        self.pointGap = _defaultSpace;
        self.xAxisView.pointGap = self.pointGap;
    }else if (self.pointGap < _defaultSpace*2){
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.xAxisView.frame;
            frame.size.width = self.xTitleArray.count * _defaultSpace*2;
            self.xAxisView.frame = frame;
        }];
        self.pointGap = _defaultSpace*2;
        self.xAxisView.pointGap = self.pointGap;
    }
    self.scrollView.contentOffset = CGPointMake(index*self.pointGap - leftMagin , 0);
    self.scrollView.contentSize = CGSizeMake(self.xAxisView.frame.size.width, CGRectGetHeight(self.xAxisView.frame));
}

//调整横向偏移 至 第一个出现的点
- (void)adjustOffsetWithFirstPoint:(CGFloat)xOffset{
    if (xOffset<0) {
        return;
    }
    if (_scrollView) {
        CGPoint offset = CGPointMake(xOffset, 0);
        if((offset.x+_scrollView.width) > _scrollView.contentSize.width){
            offset.x = _scrollView.contentSize.width - _scrollView.width;
        }else{
            offset.x -= 2;
        }
        [_scrollView setContentOffset:offset animated:YES];
        
    }
}

@end
