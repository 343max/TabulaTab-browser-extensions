//
//  TabulatabsBrowserWindow.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabulatabsBrowserWindow : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property NSInteger windowId;
@property BOOL focused;

@property (strong) NSArray *tabs;

@end
