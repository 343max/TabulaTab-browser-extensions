//
//  Browser.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTab.h"

@interface WebViewViewController : UIViewController <UIWebViewDelegate>

@property (strong) IBOutlet UIWebView *mainWebView;
@property (strong) IBOutlet UIToolbar *toolbar;

@property (strong) TTTab *browserTab;

- (IBAction)share:(id)sender;


@end