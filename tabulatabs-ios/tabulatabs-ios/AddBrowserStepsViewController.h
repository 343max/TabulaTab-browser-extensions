//
//  AddBrowserStepsViewController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface AddBrowserStepsViewController : UIViewController <ZBarReaderDelegate>

@property (strong) UIViewController *openerViewController;

- (IBAction)dismiss:(id)sender;
- (IBAction)startScanning:(id)sender;

@end
