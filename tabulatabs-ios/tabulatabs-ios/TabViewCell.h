//
//  TabChooserCell.h
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTab.h"

@interface TabViewCell : UITableViewCell <UIScrollViewDelegate>

- (void)setBackgroundViewVisible:(BOOL)visible animated:(BOOL)animated;

@property (strong, nonatomic) TTTab *tab;

@property (assign, nonatomic) BOOL backgroundViewVisible;
@property (assign, nonatomic) BOOL markedAsRead;

@end
