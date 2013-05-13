//
//  ControlLabAppDelegate.h
//  ControlLab
//
//  Created by Pablo Casado Varela on 13/02/13.
//  Copyright (c) 2013 Pablo Casado Varela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface ControlLabAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CMMotionManager *mm;

@end
