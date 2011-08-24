//
//  MWJavaScriptQueue.h
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWJavaScriptQueue : UIWebView <UIWebViewDelegate>
{
    NSMutableArray *queuedCommands;
    bool loaded;
}

- (id)initWithUrlRequest:(NSURLRequest *)urlRequest;
- (id)initWithFile:(NSString *)fileName;
- (void)executeJavaScriptAsynchronly:(NSString *)javaScriptCommand executionFinished:(void(^)(NSString *))resultCallback;
- (void)executeJavaScriptFunctionAsynchronly:(NSString *)javaScriptFunction withParameter:(NSString *)parameter executionFinished:(void(^)(NSString *))resultCallback;

@end
