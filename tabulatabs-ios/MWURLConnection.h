//
//  MWURLConnection.h
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWURLConnection : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (strong) NSMutableData *dataReceived;
@property (copy, nonatomic) void(^didFinishLoadingBlock)(NSData *);

- (id)initWithRequest:(NSURLRequest *)request;
- (void)start;
- (void)cancel;

@end
