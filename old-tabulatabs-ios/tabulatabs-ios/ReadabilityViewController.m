//
//  ReadabilityViewController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadabilityViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ReadabilityViewController

@synthesize url, doneButton, articleView, activityIndicator;

- (void)closeView:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper"]];
    
/*    doneButton.layer.cornerRadius = 0.1f;
    doneButton.layer.masksToBounds = YES;*/
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)injectCssFile:(NSString *)cssFilePath
{
    NSString *cssInjectionScript = @"function cssLoader(d) { \
    var head = document.getElementsByTagName('head')[0]; \
    var style = document.createElement('style'); style.textContent = (d); \
    head.appendChild(style);}";
    
    NSData *payloadData = [NSData dataWithContentsOfFile:cssFilePath];
    NSString *payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
    [self.articleView executeJavaScriptFunctionAsynchronly: cssInjectionScript withParameter:payloadString executionFinished:nil];
}

- (void)injectJsFile:(NSString *)jsFilePath
{
    NSString *jsInjectionScript = @"function jsLoader(d) {\
	var head = document.getElementsByTagName('head')[0];\
	var s = document.createElement('script');\
	s.textContent = (d);\
	head.appendChild(s);\
    }";

    NSData *payloadData = [NSData dataWithContentsOfFile:jsFilePath];
    NSString *payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
    [self.articleView executeJavaScriptFunctionAsynchronly: jsInjectionScript withParameter:payloadString executionFinished:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    __block ReadabilityViewController *view = self;
    
    [self.articleView setReadabilityCompleteBlock:^(void) {
        view.articleView.hidden = NO;
        view.activityIndicator.hidden = YES;
    }];
    
//    self.articleView.hidden = YES;
    self.articleView.opaque = NO;
    self.articleView.backgroundColor = [UIColor clearColor];
        
    [self.articleView loadRequest:[NSURLRequest requestWithURL:url]];
    [self injectCssFile:[[NSBundle mainBundle] pathForResource:@"iphone" ofType:@"css"]];
    [self injectCssFile:[[NSBundle mainBundle] pathForResource:@"readability" ofType:@"css"]];
    [self injectJsFile:[[NSBundle mainBundle] pathForResource:@"injectReadability" ofType:@"js"]];
    [self injectJsFile:[[NSBundle mainBundle] pathForResource:@"readability" ofType:@"js"]];
    //[self.articleView executeJavaScriptFunctionAsynchronly:@"function(receipient) {document.getElementsByTagName('body')[0].innerHTML = 'Hello ' + receipient;}" withParameter:@"world!" executionFinished:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}



@end
