//
//  AppDelegate.m
//  CoreDataDemo
//
//  Created by hello on 2019/10/18.
//  Copyright © 2019 Dio. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    return YES;
}

@end
