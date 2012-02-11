//
//  TTRestfulController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

NSString const * TTRestfulControllerAPIDomain = @"https://tabulatabs.heroku.com/";

#import "TTRestfulController.h"

@implementation TTRestfulController

- (void)sendJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters callback:(void (^)(id))callback;
{
    [self sendJsonRequest:path method:method jsonParameters:jsonParameters username:nil password:nil callback:callback];
}

- (void)sendJsonGetRequest:(NSString *)path username:(NSString *)username password:(NSString *)password callback:(void (^)(id))callback;
{
    [self sendJsonRequest:path method:@"GET" jsonParameters:nil username:username password:password callback:callback];
}

- (void)sendJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters username:(NSString *)username password:(NSString *)password callback:(void (^)(id))callback;
{
    
}

@end
