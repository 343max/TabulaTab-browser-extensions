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
    }
    
    return self;
}

@end
