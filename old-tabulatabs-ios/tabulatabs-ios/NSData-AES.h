//
//  NSData-AES.h
//  sjclDecryption
//
//  Created by Max Winde on 04.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSData *)key iv:(NSData *)iv;
- (NSData *)AES256DecryptWithKey:(NSData *)key iv:(NSData *)iv;

@end
