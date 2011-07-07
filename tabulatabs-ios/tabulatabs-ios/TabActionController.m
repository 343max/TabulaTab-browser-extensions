//
//  TabActionController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 07.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabActionController.h"

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

+ (void)launchInSafari:(TabulatabsBrowserTab *)tab 
{
    [[UIApplication sharedApplication] openURL:tab.url];
}

@end
