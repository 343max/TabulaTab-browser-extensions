//
//  BrowserRepresentation.m
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BrowserRepresentation.h"

@implementation BrowserRepresentation

@synthesize label;
@synthesize userId, userPassword, encryptionPassword;

- (id)initWithLabel:(NSString*)l userId:(NSString*)uid userPassword:(NSString*)upwd encryptionPassword:(NSString*)epwd
{
    self = [self init];
    
    if (self) {
        self.label = l;
        self.userId = uid;
        self.userPassword = upwd;
        self.encryptionPassword = epwd;
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
