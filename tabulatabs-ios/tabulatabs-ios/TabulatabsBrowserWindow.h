//
//  TabulatabsBrowserWindow.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabulatabsBrowserWindow : NSObject <NSCoding>

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSArray *)tabsContainingString:(NSString *)searchString;

@property NSInteger windowId;
@property BOOL focused;

@property (strong) NSArray *tabs;

@end
