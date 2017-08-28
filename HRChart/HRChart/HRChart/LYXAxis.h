//
//  LYXAxis.h
//  IphoneApp
//
//  Created by AppsComm on 2016/12/8.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BottomHeight 34

@interface LYGraphPoint : NSObject

@property (nonatomic,strong) NSString* time;
@property (nonatomic,assign) NSInteger value;

-(instancetype)initWithTime:(NSString*)time value:(int)value;
@end

@interface LYXAxis : UIView
@property (assign, nonatomic) CGFloat pointGap;//点之间的距离
@property (assign,nonatomic)BOOL isShowLabel;//是否显示文字

@property (assign,nonatomic)BOOL isLongPress;//是不是长按状态
@property (assign, nonatomic) CGPoint currentLoc; //长按时当前定位位置
@property (assign, nonatomic) CGPoint screenLoc; //相对于屏幕位置

@property (nonatomic, strong) NSArray *sourceData;

@property (nonatomic,assign)NSInteger maxValue;
@property (nonatomic,assign)NSInteger minValue;

@property (nonatomic,assign)CGFloat xOffset;

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin source:(NSArray *)source;
- (void)reloadData;
@end
