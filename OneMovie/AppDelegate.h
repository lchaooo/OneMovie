//
//  AppDelegate.h
//  OneMovie
//
//  Created by 李超 on 15/3/20.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileStore.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
+ (instancetype)sharedDelegate;
@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) FileStore *fileStore;

@end

