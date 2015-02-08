//
//  AppDelegate.h
//  PhotoSearch
//
//  Created by Nico on 07/02/2015.
//  Copyright (c) 2015 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCPhotoViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (nonatomic) UINavigationController *navController;
@property (nonatomic) NCPhotoViewController *viewController;

@end

