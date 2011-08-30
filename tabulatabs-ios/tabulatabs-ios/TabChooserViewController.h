//
//  TabChooserViewController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTBrowser.h"

@interface TabChooserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIScrollViewDelegate>

@property (strong) IBOutlet UISearchBar *tabSearchBar;

@property (strong) TTBrowser *browser;
@property (strong) NSArray *searchResults;

@end
