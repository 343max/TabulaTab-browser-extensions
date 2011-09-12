//
//  tabulatabs_iosAppDelegate.m
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabulatabsApp.h"

#import "BrowserChooserViewController.h"
#import "TTBrowser.h"
#import "MWImagePool.h"
#import "Helpers.h"

static TabulatabsApp* sharedTabulatabApp;
static MWImagePool *sharedImagePool;

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

#pragma mark network activity indicator

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

+ (MWImagePool *)sharedImagePool
{
    if (!sharedImagePool) {
        sharedImagePool = [[MWImagePool alloc] init];
    }
    
    return sharedImagePool;
}

#pragma mark save status

- (void)saveSettings
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:browserRepresenations forKey:@"tabulatabsBrowsers"];
    
    [archiver finishEncoding];
    
    [data writeToFile:pathInDocumentDirectory(@"settings.plist") atomically:YES];
}

- (void)restoreSettings
{
    NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:pathInDocumentDirectory(@"settings.plist")];
    
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        browserRepresenations = [unarchiver decodeObjectForKey:@"tabulatabsBrowsers"];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    BrowserChooserViewController *viewController = [[BrowserChooserViewController alloc] initWithNibName:@"BrowserChooserViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navigationController;
    
    browserRepresenations = [[NSMutableArray alloc] init];
    
    [self restoreSettings];
    
    [self application:application handleOpenURL:[NSURL URLWithString:@"tabulatabs:/register?uid=EBE8421E-9324-4258-A93B-14E33BC167D4&cid=09F4B687-DA01-47BB-BF01-AEC1B0079541&k=70f9f0f3f9dc4b7dfa0ac417aa46d2e33743e1c2c4b2c69fc836dfd307ff82d9"]];
    
    [browserRepresenations enumerateObjectsUsingBlock:^(__strong TTBrowser *browser, NSUInteger idx, BOOL *stop) {
        [browser loadTabs];
        [browser loadBrowserInfo];
        
        stop = NO;
    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
    if (!url) {
        return NO;
    }
    
    TTBrowser *newBrowser = [[TTBrowser alloc] init];
    if ([newBrowser setRegistrationUrl:url]) {
        [newBrowser claimClient];
        [browserRepresenations addObject:newBrowser];
        
        [newBrowser loadBrowserInfo];
        [newBrowser loadTabs];
    }
    
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
    [self saveSettings];
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
