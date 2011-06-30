//
//  TabChooserViewController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabulatabsBrowserRepresentation.h"

@interface TabChooserViewController : UITableViewController <UISearchBarDelegate>

@property IBOutlet UISearchBar *searchBar;

@property (strong) TabulatabsBrowserRepresentation *browser;
@property (strong) NSArray *windowsContainingSearchText;

@end
