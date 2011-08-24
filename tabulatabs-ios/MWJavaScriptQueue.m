//
//  MWJavaScriptQueue.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWJavaScriptQueue.h"

@implementation MWJavaScriptQueue

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        queuedCommands = [[NSMutableArray alloc] init];
        loaded = NO;
        [self setDelegate:self];
    }
    return self;
}

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
        if (resultCallback) {
            resultCallback(resultString);
        }
    }
}

- (void)executeJavaScriptFunctionAsynchronly:(NSString *)javaScriptFunction withParameter:(NSString *)parameter executionFinished:(void(^)(NSString *))resultCallback
{
    NSString *escapedParameter = [parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *jsBlock = [NSString stringWithFormat:@"(%@)(unescape(\"%@\"));", javaScriptFunction, escapedParameter];
    NSLog(@"%@", jsBlock);
    [self executeJavaScriptAsynchronly:jsBlock executionFinished:resultCallback];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    loaded = YES;
    for (NSArray *command in queuedCommands) {
        if (command.count >= 2) {
            [self executeJavaScriptAsynchronly:[command objectAtIndex:0] executionFinished:[command objectAtIndex:1]];
        } else {
            [self executeJavaScriptAsynchronly:[command objectAtIndex:0] executionFinished:nil];
        }
    }
    
    [queuedCommands removeAllObjects];
}

@end
