//
//  TabActionController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabActionController.h"
#import "ReadabilityViewController.h"

@implementation TabActionController

- (id)init
{
    NSAssert(false, @"TabActionController is static only");
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (void)launchInSafari:(NSURL *)url 
{
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)presentWithReadabilty:(NSURL *)url inViewContoller:(UIViewController *)parentViewController
{
    ReadabilityViewController* readabilityViewController = [[ReadabilityViewController alloc] initWithNibName:@"ReadabilityViewController" bundle:nil];
    readabilityViewController.url = url;
    [parentViewController presentModalViewController:readabilityViewController animated:YES];
}

@end
