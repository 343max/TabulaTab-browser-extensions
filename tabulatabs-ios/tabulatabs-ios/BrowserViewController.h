//
//  Browser.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabulatabsBrowserTab.h"

@interface BrowserViewController : UIViewController

@property IBOutlet UIWebView *webView;

@property (strong) TabulatabsBrowserTab *browserTab;

@end
