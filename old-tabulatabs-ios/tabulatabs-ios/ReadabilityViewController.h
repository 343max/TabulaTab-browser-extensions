//
//  ReadabilityViewController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 08.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadabilityWebView.h"

@interface ReadabilityViewController : UIViewController

@property (strong) NSURL *url;
@property (strong) IBOutlet UIButton *doneButton;
@property (strong) IBOutlet ReadabilityWebView *articleView;
@property (strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)closeView:(id)sender;


@end
