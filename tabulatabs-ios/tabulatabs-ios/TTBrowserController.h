//
//  TTBrowserController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTEncryptedRestfulController.h"

@interface TTBrowserController : TTEncryptedRestfulController

@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *description;
@property (strong) NSURL *iconURL;

- (void)registerBrowser:(NSString *)password callback:(void(^)())callback;

@end
