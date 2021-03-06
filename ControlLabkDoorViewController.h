//
//  ControlLabkDoorViewController.h
//  ControlLab
//
//  Created by Pablo Casado Varela on 26/03/13.
//  Copyright (c) 2013 Pablo Casado Varela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ControlLabBackgroundLayer.h"
#import "ControlLabWebViewDevice.h"


@interface ControlLabkDoorViewController : UIViewController<NSURLConnectionDelegate> {
    NSString *identify;

}

- (IBAction)flip:(id)sender;

- (void) getIdentify:(NSString *)device;

@end
