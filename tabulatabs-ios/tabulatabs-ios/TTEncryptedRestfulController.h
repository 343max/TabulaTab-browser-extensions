//
//  TTEncryptedRestfulController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTRestfulController.h"

@interface TTEncryptedRestfulController : TTRestfulController

@property (strong) NSData *encryptionKey;

- (id)initWithEncryptionKey:(NSData *)encryptionKey;

- (NSDictionary *)encrypt:(id)payload iv:(NSData *)iv;
- (NSDictionary *)encrypt:(id)payload;
- (id)decrypt:(NSDictionary *)encryptedDictionary;

@end
