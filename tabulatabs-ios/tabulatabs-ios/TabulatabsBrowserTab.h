//
//  TabulatabsBrowserTab.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabulatabsBrowserTab : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)containsString:(NSString *)searchString;

@property (strong) NSString *title;
@property (strong) NSURL *url;
@property (strong) NSString *shortDomain;
@property (strong) NSString *siteTitle;
@property (strong) NSString *pageTitle;
@property (strong) NSURL *favIconUrl;
@property BOOL selected;

@property (strong) UIImage *favIconImage;

@end
