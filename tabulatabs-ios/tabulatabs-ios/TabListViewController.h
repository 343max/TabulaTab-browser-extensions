//
//  TabChooserViewController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTab.h"
#import "TTBrowser.h"

#import "PullToRefreshTableViewController.h"

@interface TabListViewController : PullToRefreshTableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIScrollViewDelegate>

- (void)openPage:(TTTab *)tab;

@property (strong) IBOutlet UISearchBar *tabSearchBar;

@property (strong) TTBrowser *browser;
@property (strong) NSArray *searchResults;

@end
