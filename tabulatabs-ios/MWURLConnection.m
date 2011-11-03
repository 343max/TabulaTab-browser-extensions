//
//  MWURLConnection.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWURLConnection.h"


//{
//    NSURLConnection *connection;
//    void(^didFinishLoadingBlock)(NSData *);
//}


@interface MWURLConnection ()

@property (strong) NSURLRequest *request;
@property (strong) NSURLConnection *connection;

@end


@implementation MWURLConnection

@synthesize dataReceived;
@synthesize request, connection, didFinishLoadingBlock;

- (id)initWithRequest:(NSURLRequest *)aRequest
{
    self = [super init];
    
    if (self) {
        self.request = aRequest;
        self.dataReceived = [[NSMutableData alloc] init];
        self.connection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self startImmediately:NO];
    }
    
    return self;
}

- (void)start
{
    [self.connection start];
}

- (void)cancel
{
    [self.connection cancel];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dataReceived appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.didFinishLoadingBlock) {
        self.didFinishLoadingBlock(self.dataReceived);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Error: %@", [error description]);
}

@end
