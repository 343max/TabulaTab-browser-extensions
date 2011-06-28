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

static MWJavaScriptQueue *javaScriptClientQueue;

@implementation TabulatabsBrowserRepresentation

@synthesize label, iconId;
@synthesize userId, userPassword, encryptionPassword;
@synthesize connections;
@synthesize delegate;

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
        self.connections = [[NSMutableArray alloc] init];
        
        if (!javaScriptClientQueue) {
            javaScriptClientQueue = [[MWJavaScriptQueue alloc] initWithFile:@"iosJavaScriptIndex"];
        }
    }
    
    return self;
}

- (id)initWithLabel:(NSString*)l userId:(NSString*)uid userPassword:(NSString*)upwd encryptionPassword:(NSString*)epwd
{
    self = [self init];
    
    if (self) {
        self.label = l;
        self.userId = uid;
        self.userPassword = upwd;
        self.encryptionPassword = epwd;
    }
    
    return self;
}

- (void)refreshViews
{
    if (self.delegate) {
        [self.delegate redrawTables];
    }
}

- (BOOL)setRegistrationUrl:(NSString *)urlString
{
    self.label = NSLocalizedString(@"Registering your browser…", @"Registering your browser…");
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (![url.scheme isEqual:@"tabulatabs"]) {
        return NO;
    }
    
    if (![url.path isEqual:@"/register"]) {
        return NO;
    }
    
    NSDictionary *query = [self parseQueryString:url.query];

    self.userId = [query objectForKey:@"id"];
    self.userPassword = [query objectForKey:@"p1"];
    self.encryptionPassword = [query objectForKey:@"p2"];
    
    if ((!self.userId) | (!self.userPassword) | (!self.encryptionPassword))
        return NO;
    
    return YES;
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
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.userId, @"userId", self.userPassword, @"userPasswd", action, @"action", nil];
}

- (void)getValueForKey:(NSString *)key withDidFinishLoadingBlock:(void(^)(NSString *))didFinishLoadingBlock
{
    NSMutableDictionary *parameters = [self parametersForAction:@"get"];
    [parameters setObject:key forKey:@"key"];
    
    __block TabulatabsBrowserRepresentation *browserReprensentation = self;
    
    [self postToApi:parameters withDidFinishLoadingBlock:^(NSData *data) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result: %@", dataString);
        [browserReprensentation decryptAssynchronly:dataString didDecryptDataBlock:didFinishLoadingBlock];
    }];
}

- (void)getObjectForKey:(NSString *)key withDidFinishLoadingBlock:(void(^)(id))didFinishLoadingBlock
{
    [self getValueForKey:key withDidFinishLoadingBlock:^(NSString *data) {
        NSLog(@"getObjectForKey:%@ : %@", key, data);
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
        [self refreshViews];
    }];
}

@end
