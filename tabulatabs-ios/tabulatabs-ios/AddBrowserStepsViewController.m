//
//  AddBrowserStepsViewController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddBrowserStepsViewController.h"
#import "ZBarSDK.h"
#import "TabulatabsApp.h"
#import "TabulatabsBrowserRepresentation.h"

@implementation AddBrowserStepsViewController

@synthesize openerViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Add Browser", @"Add Browser");
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Actions

- (void)dismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)startScanning:(id)sender
{
    ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    [self presentModalViewController:reader animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
   
    for (symbol in results)
        break;
    
    TabulatabsBrowserRepresentation *browser = [[TabulatabsBrowserRepresentation alloc] init];
    
    if ([browser setRegistrationUrl:symbol.data]) {
        [browser claimClient];
        
        [self.openerViewController dismissModalViewControllerAnimated:YES];
        [[TabulatabsApp sharedInstance].browserRepresenations addObject:browser];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"updatedBrowserList" object:browser]];
        
        [browser loadBrowserInfo];
        [browser loadTabs];
        
    } else {
        // !!!TODO warn on incorrect urls
        NSLog(@"not an tabulatabs registration url");
    }
}

#pragma mark - View lifecycle

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

@end
