//
//  BrowserRepresentation.m
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TTBrowser.h"
#import "MWURLConnection.h"
#import "MWJavaScriptQueue.h"
#import "NSObject+SBJson.h"
#import "TTTab.h"

static MWJavaScriptQueue *javaScriptClientQueue;

@implementation TTBrowser

@synthesize label, iconId, browserInfoLoaded;
@synthesize userId, clientId, encryptionPassword;
@synthesize tabs;

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
        self.tabs = [[NSArray alloc] init];
        
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
        
        self.tabs = [aDecoder decodeObjectForKey:@"tabs"];
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
        //NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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

- (void)postToApi:(NSDictionary *)parameters withDidFinishLoadingBlock:(void(^)(NSData *data))didFinishLoadingBlock
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
    
    __block TTBrowser *blockSelf = self;
    
    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *data) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [blockSelf decryptAssynchronly:dataString didDecryptDataBlock:didFinishLoadingBlock];
    }];
}

- (void)getObjectForKey:(NSString *)key withDidFinishLoadingBlock:(void(^)(id))didFinishLoadingBlock
{
    [self getValueForKey:key withDidFinishLoadingBlock:^(NSString *data) {
        didFinishLoadingBlock([data JSONValue]);
    }];
}

- (void)decryptAssynchronly:(NSString*)encryptedData didDecryptDataBlock:(void(^)(NSString *decryptedString))didDecryptDataBlock
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

- (void)loadTabs;
{
    NSMutableDictionary *parameters = [self parametersForAction:@"loadTabs"];
    
    __block TTBrowser *blockSelf = self;
    
    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *responseData) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [responseString JSONValue];
        NSString *dataString = [responseDict objectForKey:@"data"];
        NSDictionary *encryptedTabs = [dataString JSONValue];
        
        NSMutableArray *newTabs = [[NSMutableArray alloc] init];
        
        for (id tabId in encryptedTabs) {
            NSString *encryptedTab = [encryptedTabs objectForKey:tabId];
            
            [blockSelf decryptAssynchronly:encryptedTab didDecryptDataBlock:^(NSString *tabString) {
                NSDictionary *tabDictionary = [tabString JSONValue];
                [newTabs addObject:[[TTTab alloc] initWithDictionary:tabDictionary]];
                
                if (newTabs.count == encryptedTabs.count) {
                    self.tabs = [NSArray arrayWithArray:newTabs];
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"updatedTabList" object:self]];
                }
            }];
            
        }
    }];
    
}

- (NSArray *)sortTabArray:(NSArray *)unsortedTabs;
{
    return [unsortedTabs sortedArrayUsingComparator:^NSComparisonResult(TTTab *tab1, TTTab *tab2) {
        if (tab1.windowId < tab2.windowId) {
            return NSOrderedAscending;
        } else if (tab1.windowId > tab2.windowId) {
            return NSOrderedDescending;
        } else if (tab1.index < tab2.index) {
            return NSOrderedAscending;
        } else if (tab1.index > tab2.index) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (void)loadImages;
{
    [tabs enumerateObjectsUsingBlock:^(TTTab *tab, NSUInteger idx, BOOL *stop) {
        [tab loadImages];
    }];
}

- (void)setTabs:(NSArray *)unsortedTabs;
{
    tabs = [self sortTabArray:unsortedTabs];
}

- (NSArray *)tabsContainingString:(NSString *)searchString
{
    return [tabs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TTTab *tab, NSDictionary *bindings) {
        return [tab containsString:searchString];
    }]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{    
    [aCoder encodeObject:self.label forKey:@"label"];
    [aCoder encodeObject:self.iconId forKey:@"iconId"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.clientId forKey:@"clientId"];
    [aCoder encodeObject:self.encryptionPassword forKey:@"encryptionPassword"];
    
    [aCoder encodeBool:self.browserInfoLoaded forKey:@"browserInfoLoaded"];
    
    [aCoder encodeObject:self.tabs forKey:@"tabs"];
}

@end