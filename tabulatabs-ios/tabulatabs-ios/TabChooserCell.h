//
//  TabChooserCell.h
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "TabulatabsBrowserTab.h"

@interface TabChooserCell : UITableViewCell <UIScrollViewDelegate>

- (void)setTitle:(NSString *)title withSiteName:(NSString *)siteName withShortDomainName:(NSString *)shortDomainName;
- (void)setFavIcon:(UIImage *)favIconUrl;
- (void)setPageThumbnail:(UIImage *)pageThumbnail;
- (void)launchSafariAction:(id)sender;
- (void)setActionViewVisibile:(BOOL)visible animated:(BOOL)animated;

@property (strong) NSURL *pageThumbnailURL;
@property (strong) UIImageView *pageThumbnailView;
@property (strong) NSURL *favIconURL;
@property (strong) UIImageView *favIconView;
@property (strong) OHAttributedLabel *labelView;
@property (strong) OHAttributedLabel *labelViewSelected;

@property (strong) UIView *primaryView;
@property (strong) UIView *actionView;

@property (strong) TabulatabsBrowserTab *browserTab;

@property (assign, nonatomic) BOOL actionViewVisibile;

@end
