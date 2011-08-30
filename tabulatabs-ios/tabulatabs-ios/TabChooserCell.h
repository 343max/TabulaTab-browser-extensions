//
//  TabChooserCell.h
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "TTTab.h"

@interface TabChooserCell : UITableViewCell <UIScrollViewDelegate>

- (void)launchSafariAction:(id)sender;
- (void)presentInReadability:(id)sender;

- (void)setActionViewVisibile:(BOOL)visible animated:(BOOL)animated;

@property (strong, nonatomic) TTTab *tab;

@property (assign, nonatomic) BOOL actionViewVisibile;
@property (assign, nonatomic) BOOL markedAsRead;

@end
