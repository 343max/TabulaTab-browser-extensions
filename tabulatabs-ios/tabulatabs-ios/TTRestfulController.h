//
//  TTRestfulController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTRestfulController : NSObject

- (void)sendJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters username:(NSString *)username password:(NSString *)password callback:(void(^)(id response))callback;
- (void)sendJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters callback:(void(^)(id response))callback;
- (void)sendJsonGetRequest:(NSString *)path username:(NSString *)username password:(NSString *)password callback:(void(^)(id response))callback;

@end
