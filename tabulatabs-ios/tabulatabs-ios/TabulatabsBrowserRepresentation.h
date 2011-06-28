//
//  BrowserRepresentation.h
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabulatabsApp.h"

@interface TabulatabsBrowserRepresentation : NSObject

@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *iconId;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userPassword;
@property (strong, nonatomic) NSString *encryptionPassword;
@property (strong, nonatomic) NSMutableArray *connections;

@property (weak) TabulatabsApp *delegate;

- (id)initWithLabel:(NSString*)l userId:(NSString*)uid userPassword:(NSString*)upwd encryptionPassword:(NSString*)epwd;
- (BOOL)setRegistrationUrl:(NSString *)urlString;
- (void)postToApi:(NSDictionary *)parameters withDidFinishLoadingBlock:(void(^)(NSData *))didFinishLoadingBlock;
- (void)decryptAssynchronly:(NSString*)encryptedData didDecryptDataBlock:(void(^)(NSString *))didDecryptDataBlock;
- (NSData *)buildQueryStringFromParameters:(NSDictionary *)parameters;
- (NSMutableDictionary *)parametersForAction:(NSString *)action;
- (void)loadBrowserInfo;

@end
