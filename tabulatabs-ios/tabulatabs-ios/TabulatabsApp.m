//
//  tabulatabs_iosAppDelegate.m
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabulatabsApp.h"

#import "BrowserChooserViewController.h"
#import "TabulatabsBrowserRepresentation.h"

static TabulatabsApp* sharedTabulatabApp;

@implementation TabulatabsApp

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize browserRepresenations;

- (id)init
{
    if (sharedTabulatabApp) {
        NSLog(@"Error: You are creating a second AppController");
    }
    self = [super init];
    
    networkProcessCount = 0;
    
    sharedTabulatabApp = self;
    
    return self;
}

- (void)addNetworkProcess
{
    networkProcessCount += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)finishNetworkPorcess
{
    networkProcessCount -= 1;
    if (networkProcessCount < 0) {
        NSLog(@"negative network process count");
    }
    
    if (networkProcessCount <= 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

+ (TabulatabsApp *)sharedInstance
{
    return sharedTabulatabApp;
}

- (void)redrawTables
{
    UIViewController *visibileViewController = self.navigationController.visibleViewController;
    if ([visibileViewController isKindOfClass:[UITableViewController class]]) {
        UITableViewController *tableViewController = (UITableViewController *)self.navigationController.visibleViewController;
        [tableViewController.tableView reloadData];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BrowserChooserViewController *viewController = [[BrowserChooserViewController alloc] initWithNibName:@"BrowserChooserViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navigationController;
    
    browserRepresenations = [[NSMutableArray alloc] init];
    
    TabulatabsBrowserRepresentation *browser = [[TabulatabsBrowserRepresentation alloc] init];
    if ([browser setRegistrationUrl:@"tabulatabs:/register?id=CDE0FEDA-97DB-40EB-B928-385A853ECF90&p1=umln3D1Duu53n9rFSygJYZppPFy69039&p2=lAcy4O7BJd8ilxf2izwJpnWKhSs3YBhj"]) {
        [browser setDelegate:self];
        [browser loadBrowserInfo];
        [browserRepresenations addObject:browser];
    }
    
    [browserRepresenations enumerateObjectsUsingBlock:^(__strong TabulatabsBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        [browser loadWindowsAndTabs];
        
        stop = NO;
    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
