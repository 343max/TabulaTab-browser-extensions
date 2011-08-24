//
//  Browser.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"
#import "TabulatabsApp.h"
#import "TabActionController.h"

@implementation BrowserViewController

@synthesize browserTab;
@synthesize mainWebView, toolbar;

- (void)share:(id)sender
{
    NSURL *url = browserTab.url;
    if (![mainWebView.request.URL.absoluteString isEqualToString:@""]) {
        url = mainWebView.request.URL;
    }
    [TabActionController launchInSafari:url];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)viewWillAppear:(BOOL)animated
{
    self.title = browserTab.title;
    self.mainWebView.scalesPageToFit = YES;
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:browserTab.url]];
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[TabulatabsApp sharedInstance] addNetworkProcess];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[TabulatabsApp sharedInstance] finishNetworkPorcess];
    
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
