//
//  AppDelegate.h
//  HRChart
//
//  Created by AppsComm on 2017/8/28.
//  Copyright © 2017年 quzhongrensan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

