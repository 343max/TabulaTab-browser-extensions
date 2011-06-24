//
//  tabulatabs_iosAppDelegate.h
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserChooserViewController;

@interface TabulatabsApp : UIResponder <UIApplicationDelegate>

+ (TabulatabsApp *)sharedInstance;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BrowserChooserViewController *viewController;
@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSMutableArray *browserRepresenations;

@end
