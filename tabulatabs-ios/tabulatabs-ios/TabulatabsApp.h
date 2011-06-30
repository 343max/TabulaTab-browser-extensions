//
//  tabulatabs_iosAppDelegate.h
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePool.h"

@class BrowserChooserViewController;

@interface TabulatabsApp : UIResponder <UIApplicationDelegate>
{
    int networkProcessCount;
}

+ (TabulatabsApp *)sharedInstance;
+ (ImagePool *)sharedImagePool;

- (void)addNetworkProcess;
- (void)finishNetworkPorcess;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) NSMutableArray *browserRepresenations;

@end
