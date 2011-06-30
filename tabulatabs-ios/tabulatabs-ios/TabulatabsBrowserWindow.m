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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
    if (self) {
        windowId = [aDecoder decodeIntegerForKey:@"windowId"];
        focused = [aDecoder decodeBoolForKey:@"focused"];
        
        tabs = [aDecoder decodeObjectForKey:@"tabs"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:windowId forKey:@"windowId"];
    [aCoder encodeBool:focused forKey:@"focused"];
    
    [aCoder encodeObject:tabs forKey:@"tabs"];
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

- (NSArray *)tabsContainingString:(NSString *)searchString
{
    return [self.tabs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TabulatabsBrowserTab *tab, NSDictionary *bindings) {
        return [tab containsString:searchString];
    }]];
}

@end
