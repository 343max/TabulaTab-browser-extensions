//
//  TabulatabsBrowserTab.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TTTab.h"


NSString * const TTTabFavIconChangedNotification = @"TTTabFavIconChangedNotification";
NSString * const TTTabPageThumbnailChangedNotification = @"TTTabPageThumbnailChangedNotification";


@implementation TTTab

@synthesize title, url, favIconUrl, selected;
@synthesize shortDomain, siteTitle, pageTitle;
@synthesize windowId;
@synthesize index;
@synthesize favIconImage;
@synthesize pageThumbnailUrl;
@synthesize pageThumbnailImage;


- (void)setFavIconImage:(UIImage *)newFavIconImage;
{
    favIconImage = newFavIconImage;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTTabFavIconChangedNotification object:self];
}

- (void)setPageThumbnailImage:(UIImage *)newPageThumbnailImage;
{
    pageThumbnailImage = newPageThumbnailImage;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTTabPageThumbnailChangedNotification object:self];
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (TTTab *)tabWithURL:(NSURL *)url
{
    TTTab *tab = [[TTTab alloc] init];
    if (tab) {
        tab.url = url;
    }
    return tab;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        self.selected = [(NSNumber *)[dictionary objectForKey:@"selected"] integerValue] != 0;
        self.title = [dictionary valueForKey:@"title"];
        self.url = [NSURL URLWithString:[dictionary valueForKey:@"url"]];
        self.shortDomain = [dictionary objectForKey:@"shortDomain"];
        self.siteTitle = [dictionary objectForKey:@"siteTitle"];
        self.pageTitle = [dictionary objectForKey:@"pageTitle"];
        self.favIconUrl = [NSURL URLWithString:[dictionary objectForKey:@"favIconUrl"]];
        self.pageThumbnailUrl = [NSURL URLWithString:[dictionary objectForKey:@"pageThumbnail"]];
        
        self.windowId = [[dictionary objectForKey:@"windowId"] integerValue];
        self.index = [[dictionary objectForKey:@"index"] integerValue];
    }
    
    return self;
}

- (BOOL)containsString:(NSString *)searchString
{
    return ([self.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) | ([self.shortDomain rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        selected = [aDecoder decodeBoolForKey:@"selected"];
        title = [aDecoder decodeObjectForKey:@"title"];
        url = [aDecoder decodeObjectForKey:@"url"];
        shortDomain = [aDecoder decodeObjectForKey:@"shortDomain"];
        siteTitle = [aDecoder decodeObjectForKey:@"siteTitle"];
        pageTitle = [aDecoder decodeObjectForKey:@"pageTitle"];
        favIconUrl = [aDecoder decodeObjectForKey:@"favIconUrl"];
        pageThumbnailUrl = [aDecoder decodeObjectForKey:@"pageThumbnailUrl"];
        
        windowId = [aDecoder decodeIntegerForKey:@"windowId"];
        index = [aDecoder decodeIntegerForKey:@"index"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:selected forKey:@"selected"];
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:url forKey:@"url"];
    [aCoder encodeObject:shortDomain forKey:@"shortDomain"];
    [aCoder encodeObject:siteTitle forKey:@"siteTitle"];
    [aCoder encodeObject:pageTitle forKey:@"pageTitle"];
    [aCoder encodeObject:favIconUrl forKey:@"favIconUrl"];
    [aCoder encodeObject:pageThumbnailUrl forKey:@"pageThumbnailUrl"];
    
    [aCoder encodeInteger:windowId forKey:@"windowId"];
    [aCoder encodeInteger:index forKey:@"index"];
}

@end
