//
//  TabulatabsBrowserTab.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabulatabsBrowserTab.h"

@implementation TabulatabsBrowserTab

@synthesize title, url, selected;
@synthesize shortDomain, siteTitle, pageTitle;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
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
    }
    
    return self;
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
}

@end
