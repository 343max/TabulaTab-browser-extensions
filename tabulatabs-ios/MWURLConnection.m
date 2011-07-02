//
//  MWURLConnection.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWURLConnection.h"

@implementation MWURLConnection

@synthesize dataReceived;

- (void)setDidFinishLoadingBlock:(void(^)(NSData *))dflb
{
    didFinishLoadingBlock = dflb;
}

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    
    if (self) {
        self.dataReceived = [[NSMutableData alloc] init];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    }
    
    return self;
}

- (void)start
{
    [connection start];
}

- (void)cancel
{
    [connection cancel];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dataReceived appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (didFinishLoadingBlock) {
        didFinishLoadingBlock(self.dataReceived);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Error: %@", [error description]);
}

@end
