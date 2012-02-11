//
//  TabulatabsBrowserTab.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabulatabsApp.h"

#import "Helpers.h"

#import "TTTab.h"


NSString * const TTTabFavIconChangedNotification = @"TTTabFavIconChangedNotification";
NSString * const TTTabPageThumbnailChangedNotification = @"TTTabPageThumbnailChangedNotification";


@implementation TTTab

@synthesize title, url, favIconUrl, selected;
@synthesize shortDomain, siteTitle, pageTitle;
@synthesize windowId;
@synthesize index;
@synthesize tabId;
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

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@ - %@", self.pageTitle, self.url.absoluteString];
}

- (void)loadImages;
{
    if (self.favIconUrl && !self.favIconImage) {
        __block TTTab *blockSelf = self;
        
        [[TabulatabsApp sharedImagePool] fetchImageToPool:[NSURLRequest requestWithURL:self.favIconUrl] imageLoadedBlock:^(UIImage *image) {
            blockSelf.favIconImage = image;
        }];
    }
    
    if (self.pageThumbnailUrl && !self.pageThumbnailImage) {
        __block TTTab *blockSelf = self;
        
        [[TabulatabsApp sharedImagePool] fetchImageToPool:[NSURLRequest requestWithURL:self.pageThumbnailUrl] imageLoadedBlock:^(UIImage *imageData) {
            blockSelf.pageThumbnailImage = scaleImageToMinSize(imageData, CGSizeMake(256.0, 144.0));
        }];
    }

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
        self.tabId = [[dictionary objectForKey:@"id"] integerValue];
    }
    
    return self;
}

- (BOOL)containsString:(NSString *)searchString
{
    if (searchString) {
        return ([self.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) | ([self.shortDomain rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound);
    } else {
        return YES;
    }
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
        tabId = [aDecoder decodeIntegerForKey:@"tabId"];
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
    [aCoder encodeInteger:tabId forKey:@"tabId"];
}

@end
