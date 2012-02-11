//
//  tabulatabs_iosTests.m
//  tabulatabs-iosTests
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TTBrowserController.h"

#import "tabulatabs_iosTests.h"

@implementation tabulatabs_iosTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testEncryption;
{
    NSString *keyString = @"secretsecretsecretsecretsecretAA";
    NSString *ivString = @"iviviviviviviviv";

    TTBrowserController *browser = [[TTBrowserController alloc] initWithEncryptionKey:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *payload = [NSDictionary dictionaryWithObject:@"World!" forKey:@"hello"];
    
    NSDictionary *encryptedData = [browser encrypt:payload iv:[ivString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *decryptedPayload = [browser decrypt:encryptedData];
    
    STAssertEquals([decryptedPayload objectForKey:@"hello"], @"World!", @"encryption/decryption did work");
}

@end
