//
//  AppDelegate.m
//  OneMovie
//
//  Created by 李超 on 15/3/20.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize fileStore = _fileStore;

+ (instancetype)sharedDelegate{
    return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (FileStore *)fileStore{
    if (_fileStore == nil) {
        _fileStore = [FileStore fileStore];
    }
    return _fileStore;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
