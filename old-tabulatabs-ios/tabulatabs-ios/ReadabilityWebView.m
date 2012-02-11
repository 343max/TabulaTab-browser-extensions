//
//  ReadabilityWebView.m
//  tabulatabs-ios
//
//  Created by Max Winde on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadabilityWebView.h"

@implementation ReadabilityWebView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setReadabilityCompleteBlock:(void (^)(void))completeBlock {
    readabilityCompleteBlock = completeBlock;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", [[request URL] absoluteString]);
    
    NSLog(@"Should start loading: %@ (URL: %@)", [request valueForHTTPHeaderField:@"Content-Type"], [[request URL] absoluteString]);
    
    if ([[[request URL] absoluteString] isEqualToString:@"app:doneloading"]) {
        if (readabilityCompleteBlock) {
            readabilityCompleteBlock();
        }
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[[request URL] absoluteURL]];
        return NO;
    }
    return YES;
}

@end
