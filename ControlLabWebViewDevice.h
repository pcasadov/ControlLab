//
//  ControlLabWebViewDevice.h
//  ControlLab
//
//  Created by Pablo Casado Varela on 26/03/13.
//  Copyright (c) 2013 Pablo Casado Varela. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ControlLabWebViewDevice : UIImageView <NSURLConnectionDelegate>

- (void) closeControlLabWebViewDevice;
- (void) getIdDevice:(NSString*)device;
@end
