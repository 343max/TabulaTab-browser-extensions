//
//  BrowserRepresentation.m
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabulatabsBrowserRepresentation.h"
#import "MWURLConnection.h"
#import "MWJavaScriptQueue.h"
#import "NSObject+SBJson.h"
#import "TabulatabsBrowserWindow.h"

static MWJavaScriptQueue *javaScriptClientQueue;

@implementation TabulatabsBrowserRepresentation

@synthesize label, iconId, browserInfoLoaded;
@synthesize userId, clientId, encryptionPassword;
@synthesize windows;

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.windows = [[NSArray alloc] init];
        
        if (!javaScriptClientQueue) {
            javaScriptClientQueue = [[MWJavaScriptQueue alloc] initWithFile:@"iosJavaScriptIndex"];
        }
    }
    
    return self;
}

- (id)initWithLabel:(NSString*)l userId:(NSString*)uid clientId:(NSString*)cid encryptionPassword:(NSString*)epwd
{
    self = [self init];
    
    if (self) {
        self.label = l;
        self.userId = uid;
        self.clientId = cid;
        self.encryptionPassword = epwd;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        self.label = [aDecoder decodeObjectForKey:@"label"];
        self.iconId = [aDecoder decodeObjectForKey:@"iconId"];
        
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.clientId = [aDecoder decodeObjectForKey:@"clientId"];
        self.encryptionPassword = [aDecoder decodeObjectForKey:@"encryptionPassword"];
        
        browserInfoLoaded = [aDecoder decodeBoolForKey:@"browserInfoLoaded"];
        
        self.windows = [aDecoder decodeObjectForKey:@"windows"];
    }
    
    return self;
}

- (BOOL)setRegistrationUrl:(NSString *)urlString
{
    browserInfoLoaded = NO;
    
    self.label = NSLocalizedString(@"Registering your browser…", @"Registering your browser…");
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (![url.scheme isEqual:@"tabulatabs"]) {
        return NO;
    }
    
    if (![url.path isEqual:@"/register"]) {
        return NO;
    }
    
    NSDictionary *query = [self parseQueryString:url.query];

    self.userId = [query objectForKey:@"uid"];
    self.clientId = [query objectForKey:@"cid"];
    self.encryptionPassword = [query objectForKey:@"p"];
    
    if ((!self.userId) | (!self.clientId) | (!self.encryptionPassword))
        return NO;
    
    return YES;
}

- (void)claimClient
{
    NSMutableDictionary *parameters = [self parametersForAction:@"claimClient"];

    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *data) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }];
}

- (NSData *)buildQueryStringFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *encodedParameters = [[NSMutableArray alloc] init];
    
    for (NSString *key in parameters) {
        NSString *value = [parameters objectForKey:key];
        [encodedParameters addObject:[NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    return [[encodedParameters componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)postToApi:(NSDictionary *)parameters withDidFinishLoadingBlock:(void(^)(NSData *))didFinishLoadingBlock
{
    /*NSLog(@"postToApi:");
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSLog(@"%@=%@", key, value);
    }];*/
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://apiv0.tabulatabs.com/"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self buildQueryStringFromParameters:parameters];
    
    MWURLConnection *connection = [[MWURLConnection alloc] initWithRequest:request];
    [connection setDidFinishLoadingBlock:^(NSData *data) {
        didFinishLoadingBlock(data);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
    [connection start];
}

- (NSMutableDictionary *)parametersForAction:(NSString *)action
{
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.userId, @"userId", self.clientId, @"clientId", action, @"action", nil];
}

- (void)getValueForKey:(NSString *)key withDidFinishLoadingBlock:(void(^)(NSString *))didFinishLoadingBlock
{
    NSMutableDictionary *parameters = [self parametersForAction:@"get"];
    [parameters setObject:key forKey:@"key"];
    
    __block TabulatabsBrowserRepresentation *browserReprensentation = self;
    
    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *data) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [browserReprensentation decryptAssynchronly:dataString didDecryptDataBlock:didFinishLoadingBlock];
    }];
}

- (void)getObjectForKey:(NSString *)key withDidFinishLoadingBlock:(void(^)(id))didFinishLoadingBlock
{
    [self getValueForKey:key withDidFinishLoadingBlock:^(NSString *data) {
        didFinishLoadingBlock([data JSONValue]);
    }];
}

- (void)decryptAssynchronly:(NSString*)encryptedData didDecryptDataBlock:(void(^)(NSString *))didDecryptDataBlock
{
    NSString *jsonValue = [[NSArray arrayWithObjects:self.encryptionPassword, encryptedData, nil] JSONRepresentation];
    [javaScriptClientQueue executeJavaScriptAsynchronly:[NSString stringWithFormat:@"decrypt(%@);", jsonValue] executionFinished:didDecryptDataBlock];
}

- (void)loadBrowserInfo
{
    [self getObjectForKey:@"browserInfo" withDidFinishLoadingBlock:^(NSDictionary *browserInfo) {
        self.label = [browserInfo objectForKey:@"label"];
        self.iconId = [browserInfo objectForKey:@"icon"];
        browserInfoLoaded = YES;
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"updatedBrowserList" object:self]];
    }];
}

- (void)loadWindowsAndTabs
{
    [self getObjectForKey:@"browserTabs" withDidFinishLoadingBlock:^(NSArray *rawWindows) {
        self.windows = [[NSArray alloc] init];
        
        for (NSDictionary *rawWindow in rawWindows) {
            self.windows = [self.windows arrayByAddingObject:[[TabulatabsBrowserWindow alloc] initWithDictionary:rawWindow]];
        }

        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"updatedTabList" object:self]];
    }];
}

- (NSArray *)tabsContainingString:(NSString *)searchString
{
    __block NSArray *searchResults = [[NSArray alloc] init];
    
    [self.windows enumerateObjectsUsingBlock:^(TabulatabsBrowserWindow *window, NSUInteger idx, BOOL *stop) {
        NSArray *tabs = [window tabsContainingString:searchString];
        if ([tabs count] > 0) {
            searchResults = [searchResults arrayByAddingObject:tabs];
        }
    }];
    
    return searchResults;
}

- (NSArray *)allTabs
{
    __block NSArray *searchResults = [[NSArray alloc] init];
    
    [self.windows enumerateObjectsUsingBlock:^(TabulatabsBrowserWindow *window, NSUInteger idx, BOOL *stop) {
        searchResults = [searchResults arrayByAddingObject:window.tabs];
    }];
    
    return searchResults;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{    
    [aCoder encodeObject:self.label forKey:@"label"];
    [aCoder encodeObject:self.iconId forKey:@"iconId"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.clientId forKey:@"clientId"];
    [aCoder encodeObject:self.encryptionPassword forKey:@"encryptionPassword"];
    
    [aCoder encodeBool:self.browserInfoLoaded forKey:@"browserInfoLoaded"];
    
    [aCoder encodeObject:self.windows forKey:@"windows"];
}

@end
