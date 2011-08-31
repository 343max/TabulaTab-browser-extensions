//
//  TabulatabsBrowserTab.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TTTabFavIconChangedNotification;
extern NSString * const TTTabPageThumbnailChangedNotification;


@interface TTTab : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)containsString:(NSString *)searchString;
- (void)loadImages;

+ (TTTab *)tabWithURL:(NSURL *)url;

@property (strong) NSString *title;
@property (strong) NSURL *url;
@property (strong) NSString *shortDomain;
@property (strong) NSString *siteTitle;
@property (strong) NSString *pageTitle;
@property (strong) NSURL *favIconUrl;
@property (strong) NSURL *pageThumbnailUrl;
@property BOOL selected;
@property (assign) NSUInteger windowId;
@property (assign) NSUInteger index;

@property (strong, nonatomic) UIImage *favIconImage;
@property (strong, nonatomic) UIImage *pageThumbnailImage;

@end
