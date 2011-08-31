//
//  BrowserRepresentation.h
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabulatabsApp.h"

@interface TTBrowser : NSObject <NSCoding>

@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *iconId;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *encryptionPassword;

@property (readonly) BOOL browserInfoLoaded;

@property (strong, nonatomic) NSArray *tabs;

- (id)initWithLabel:(NSString*)l userId:(NSString*)uid clientId:(NSString*)cid encryptionPassword:(NSString*)epwd;
- (BOOL)setRegistrationUrl:(NSString *)urlString;
- (void)claimClient;
- (void)postToApi:(NSDictionary *)parameters withDidFinishLoadingBlock:(void(^)(NSData *data))didFinishLoadingBlock;
- (void)decryptAssynchronly:(NSString*)encryptedData didDecryptDataBlock:(void(^)(NSString *decryptedString))didDecryptDataBlock;
- (NSData *)buildQueryStringFromParameters:(NSDictionary *)parameters;
- (NSMutableDictionary *)parametersForAction:(NSString *)action;
- (void)loadBrowserInfo;
- (void)loadTabs;
- (void)loadImages;

- (NSArray *)tabsContainingString:(NSString *)searchString;

@end
