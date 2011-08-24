//
//  TabActionController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabActionController : NSObject

+ (void)launchInSafari:(NSURL *)url;
+ (void)presentWithReadabilty:(NSURL *)url inViewContoller:(UIViewController *)parentViewController;

@end
