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
#import "NSData-hex.h"
#import "NSData-AES.h"
#import "NSData+Base64.h"
#import "TTTab.h"

@interface TTBrowser () {
@private
    NSData *encryptionKey;
}

@end


static MWJavaScriptQueue *javaScriptClientQueue;

@implementation TTBrowser

@synthesize label, iconId, browserInfoLoaded;
@synthesize userId;
@synthesize clientId;
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        self.label = [aDecoder decodeObjectForKey:@"label"];
        self.iconId = [aDecoder decodeObjectForKey:@"iconId"];
        
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.clientId = [aDecoder decodeObjectForKey:@"clientId"];
        encryptionKey = [aDecoder decodeObjectForKey:@"encryptionKey"];
        
        browserInfoLoaded = [aDecoder decodeBoolForKey:@"browserInfoLoaded"];
        
        self.tabs = [aDecoder decodeObjectForKey:@"tabs"];
    }
    
    return self;
}

- (BOOL)setRegistrationUrl:(NSURL *)url
{
    browserInfoLoaded = NO;
    
    self.label = NSLocalizedString(@"Registering your browser…", @"Registering your browser…");
    
    if (![url.scheme isEqual:@"tabulatabs"]) {
        return NO;
    }
    
    if (![url.path isEqual:@"/register"]) {
        return NO;
    }
    
    NSDictionary *query = [self parseQueryString:url.query];

    self.userId = [query objectForKey:@"uid"];
    self.clientId = [query objectForKey:@"cid"];
    NSString *hexKey = [query objectForKey:@"k"];
    if ([hexKey length] != 64) return NO;
    encryptionKey = [NSData dataWithHexString:hexKey];
    
    if ((!self.userId) | (!self.clientId) | (!hexKey))
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
//    NSLog(@"postToApi:");
//    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
//        NSLog(@"%@=%@", key, value);
//    }];
    
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

- (void)getObjectForKey:(NSString *)key withDidFinishLoadingBlock:(void(^)(id))didFinishLoadingBlock
{
    NSMutableDictionary *parameters = [self parametersForAction:@"get"];
    [parameters setObject:key forKey:@"key"];
    
    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *data) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *response = [json JSONValue];
        
        if ([[response objectForKey:@"response"] isEqualToString:@"ok"]) {
            didFinishLoadingBlock([self decrypt:[response objectForKey:@"data"]]);
        } else {
            NSLog(@"something went wrong when trying to fetch object for key %@: %@", key, [response objectForKey:@"error"]);
            return;
            didFinishLoadingBlock(nil);
        }
        
    }];
}

- (id)decrypt:(NSDictionary *)encrypted;
{
    NSData *iv = [NSData dataWithHexString:[encrypted objectForKey:@"iv"]];
    NSData *encryptedData = [NSData dataFromBase64String:[encrypted objectForKey:@"ic"]];
    
    NSData *unencryptedData = [encryptedData AES256DecryptWithKey:encryptionKey iv:iv];
    NSString *unencryptedJson = [[NSString alloc] initWithData:unencryptedData encoding:NSUTF8StringEncoding];
    
    id unencryptedObject = [unencryptedJson JSONValue];
    if (unencryptedObject == nil) {
        NSLog(@"JSON could not be parsed: %@", unencryptedJson);
    }
    return unencryptedObject;
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
    
    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *responseData) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [responseString JSONValue];
        NSDictionary *encryptedTabs = [responseDict objectForKey:@"data"];
        
        NSMutableArray *newTabs = [[NSMutableArray alloc] init];
                
        for (NSString* tabId in encryptedTabs) {
            NSDictionary *encryptedTab = [encryptedTabs objectForKey:tabId];
            NSDictionary *tabDictionary = [self decrypt:encryptedTab];
            
            [newTabs addObject:[[TTTab alloc] initWithDictionary:tabDictionary]];            
        }
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.tabs forKey:@"oldTabs"];
        
        self.tabs = [NSArray arrayWithArray:newTabs];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"updatedTabList" object:self userInfo:userInfo]];
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
    [aCoder encodeObject:encryptionKey forKey:@"encryptionKey"];
    
    [aCoder encodeBool:self.browserInfoLoaded forKey:@"browserInfoLoaded"];
    
    [aCoder encodeObject:self.tabs forKey:@"tabs"];
}

@end
