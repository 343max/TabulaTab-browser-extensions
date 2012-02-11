//
//  MWJavaScriptQueue.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWJavaScriptQueue.h"

typedef void (^MWJavaScriptCallback)(NSString *);

@interface MWJavaScriptQueuedCommand : NSObject

@property (strong) NSString *javaScriptCommand;
@property (copy) MWJavaScriptCallback callbackBlock;

@end

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
        MWJavaScriptQueuedCommand *command = [[MWJavaScriptQueuedCommand alloc] init];
        command.javaScriptCommand = javaScriptCommand;
        command.callbackBlock = resultCallback;
        
        [queuedCommands addObject:command];
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
    for (MWJavaScriptQueuedCommand *command in queuedCommands) {
        [self executeJavaScriptAsynchronly:command.javaScriptCommand executionFinished:command.callbackBlock];
    }
    
    [queuedCommands removeAllObjects];
}

@end

@implementation MWJavaScriptQueuedCommand

@synthesize javaScriptCommand;
@synthesize callbackBlock;

@end
