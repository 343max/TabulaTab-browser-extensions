//
//  BrowserRepresentation.h
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowserRepresentation : NSObject

@property (strong, nonatomic) NSString *label;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *encryptionPassword;

- (id)initWithLabel:(NSString*)l userId:(NSString*)uid userPassword:(NSString*)upwd encryptionPassword:(NSString*)epwd;

@end
