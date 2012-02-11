//
//  TTEncryptedRestfulController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData+Base64.h"
#import "NSData-hex.h"
#import "NSData-AES.h"

#import "TTEncryptedRestfulController.h"

@implementation TTEncryptedRestfulController

@synthesize encryptionKey;

- (id)initWithEncryptionKey:(NSData *)theEncryptionKey;
{
    self = [super init];
    
    if (self) {
        self.encryptionKey = theEncryptionKey;
    }
    
    return self;
}

- (NSDictionary *)encrypt:(id)payload iv:(NSData *)iv;
{
    NSError *error;
    NSData *jsonPayload = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    NSData *ic = [jsonPayload AES256EncryptWithKey:self.encryptionKey iv:iv];
    
    return [NSDictionary dictionaryWithObjectsAndKeys: ic, @"ic", [iv base64EncodedString], @"iv", nil];
}

- (id)decrypt:(NSDictionary *)encryptedDictionary;
{
    NSData *iv = [NSData dataWithHexString:[encryptedDictionary objectForKey:@"iv"]];
    NSData *ic = [NSData dataFromBase64String:[encryptedDictionary objectForKey:@"ic"]];
    
    NSData *decryptedData = [ic AES256DecryptWithKey:self.encryptionKey iv:iv];
    NSError *error;
    id payload = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&error];
    
    if (error) {
        NSLog(@"could not decrypt data: %@", error);
    }
    
    return payload;
}

@end
