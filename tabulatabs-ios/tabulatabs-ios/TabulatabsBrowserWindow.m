//
//  TabulatabsBrowserWindow.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabulatabsBrowserWindow.h"
#import "TabulatabsBrowserTab.h"

@implementation TabulatabsBrowserWindow

@synthesize windowId, focused;
@synthesize tabs;

- (id)init
{
    self = [super init];
    if (self) {
        self.tabs = [[NSArray alloc] init];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    
    if (self) {
        self.windowId = [(NSNumber *)[dictionary objectForKey:@"id"] integerValue];
        self.focused = [(NSNumber *)[dictionary objectForKey:@"focused"] integerValue] != 0;
        
        NSArray *rawTabs = [dictionary objectForKey:@"tabs"];
        for (NSDictionary *rawTab in rawTabs) {
            self.tabs = [self.tabs arrayByAddingObject:[[TabulatabsBrowserTab alloc] initWithDictionary:rawTab]];
        }
    }
    
    return self;
}

@end
