//
//  MWJavaScriptQueue.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWJavaScriptQueue.h"

@implementation MWJavaScriptQueue

- (id)init
{
    self = [super init];
    if (self) {
        queuedCommands = [[NSMutableArray alloc] init];
        loaded = NO;
        [self setDelegate:self];
    }
    
    return self;
}

- (id)initWithUrlRequest:(NSURLRequest *)urlRequest
{
    self = [self init];
    
    if (self) {
        [self loadRequest:urlRequest];
    }
    
    return self;
}

- (id)initWithFile:(NSString *)fileName
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"html"];
    return [self initWithUrlRequest:[NSURLRequest requestWithURL:url]];
}

- (void)executeJavaScriptAsynchronly:(NSString *)javaScriptCommand executionFinished:(void(^)(NSString *))resultCallback
{
    if (!loaded) {
        [queuedCommands addObject:[NSArray arrayWithObjects:javaScriptCommand, resultCallback, nil]];
    } else {
        NSString *resultString = [self stringByEvaluatingJavaScriptFromString:javaScriptCommand];
        resultCallback(resultString);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    loaded = YES;
    
    for (NSArray *command in queuedCommands) {
        [self executeJavaScriptAsynchronly:[command objectAtIndex:0] executionFinished:[command objectAtIndex:1]];
    }
}

@end
