//
//  TabChooserCell.h
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TISwipeableTableView.h"
#import "OHAttributedLabel.h"

@interface TabChooserCell : UITableViewCell
{
    NSRange secondaryLineRange;
    NSRange mainLineRange;
}

- (void)setTitle:(NSString *)title withSiteName:(NSString *)siteName withShortDomainName:(NSString *)shortDomainName;
- (void)setFavIcon:(UIImage *)favIconUrl;

@property (strong) UIImageView *favIconView;
@property (strong) OHAttributedLabel *labelView;
@property (strong) OHAttributedLabel *labelViewSelected;

@end
