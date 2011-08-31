//
//  TabChooserCell.m
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSAttributedString+Attributes.h"

#import "TabulatabsApp.h"

#import "TabActionController.h"

#import "TabChooserCell.h"



const CGFloat kTabChooserCellBackgroundCrack = 60.0;
const CGFloat kTabChooserCellLabelRest = 80.0;



@interface TabChooserCell () {
@private
    UIScrollView *scrollView;
    UIImageView *tableCellLeftShadowView;
    UIImageView *tableCellRightShadowView;
    UIButton *showPageButton;
    
    
    NSURL *pageThumbnailURL;
    UIImageView *pageThumbnailView;
    NSURL *favIconURL;
    UIImageView *favIconView;
    OHAttributedLabel *labelView;
    OHAttributedLabel *labelViewSelected;
    
    UIView *primaryView;
    UIView *actionView;
}

- (void)faviconDidChange:(NSNotification *)notification;
- (void)pageThumbnailDidChange:(NSNotification *)notification;
- (void)layoutPageThumbnail;

@end




@implementation TabChooserCell

@synthesize tab;
@synthesize actionViewVisibile;
@synthesize markedAsRead;

- (void)setTab:(TTTab *)aTab;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabFavIconChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabPageThumbnailChangedNotification object:nil];
    
    tab = aTab;
    
    NSString *secondaryLine = ([tab.siteTitle isEqualToString:@""] ? tab.shortDomain : tab.siteTitle);
    NSString *mainLine = tab.title;
    
    NSRange secondaryLineRange = NSMakeRange(0, [secondaryLine length]);
    NSRange mainLineRange = NSMakeRange([secondaryLine length] + 1, [mainLine length]);
    
    NSMutableAttributedString *labelText = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@\n%@", secondaryLine, mainLine]];
    [labelText setTextColor:[UIColor darkGrayColor] range:secondaryLineRange];
    [labelText setFont:[UIFont fontWithName:@"Palatino-Bold" size:16.0] range:mainLineRange];
    [labelText setFont:[UIFont fontWithName:@"Palatino" size:12.0] range:secondaryLineRange];
    labelView.attributedText = labelText;
    
    NSMutableAttributedString *labelTextSelected = [NSMutableAttributedString attributedStringWithAttributedString:labelText];
    [labelTextSelected setTextColor:[UIColor whiteColor]];
    labelViewSelected.attributedText = labelTextSelected;
    
    favIconView.image = tab.favIconImage;
    pageThumbnailView.image = tab.pageThumbnailImage;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faviconDidChange: ) name:TTTabFavIconChangedNotification object:tab];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageThumbnailDidChange:) name:TTTabPageThumbnailChangedNotification object:tab];
    
    [self setNeedsLayout];
}

- (void)setActionViewVisibile:(BOOL)visible animated:(BOOL)animated;
{
    actionViewVisibile = visible;
    
    CGPoint contentOffset = CGPointMake(0.0, 0.0);
    if (!visible) {
        contentOffset.x = self.bounds.size.width - kTabChooserCellBackgroundCrack - kTabChooserCellLabelRest;
    }

    [scrollView setContentOffset:contentOffset animated:animated];
}

- (void)setActionViewVisibile:(BOOL)aActionViewVisibile;
{
    [self setActionViewVisibile:aActionViewVisibile animated:NO];
}

- (void)setMarkedAsRead:(BOOL)aMarkedAsRead;
{
    markedAsRead = aMarkedAsRead;
    
    if (markedAsRead) {
        labelView.alpha = 0.3;
        favIconView.alpha = 0.3;
        pageThumbnailView.alpha = 0.3;
        tableCellLeftShadowView.alpha = 0.3;
        tableCellRightShadowView.alpha = 0.3;
    } else {
        labelView.alpha = 1.0;
        favIconView.alpha = 1.0;
        pageThumbnailView.alpha = 1.0;
        tableCellLeftShadowView.alpha = 1.0;
        tableCellRightShadowView.alpha = 1.0;
    }
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    labelView.hidden = highlighted;
    labelViewSelected.hidden = !highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    labelView.hidden = selected;
    labelViewSelected.hidden = !selected;
}



#pragma mark Lifecycle


- (void)prepareForReuse
{
    [super prepareForReuse];
    self.actionViewVisibile = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabFavIconChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabPageThumbnailChangedNotification object:nil];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabFavIconChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabPageThumbnailChangedNotification object:nil];
}

- (void)hideOtherCellsActionView
{
    NSAssert(self.superview != nil, @"SuperView of TableCell set");
    
    UITableView *tableview = (UITableView *)self.superview;
    
    [tableview.visibleCells enumerateObjectsUsingBlock:^(TabChooserCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell != self) {
            [cell setActionViewVisibile:NO animated:YES];
        }
    }];
}

- (void)launchSafariAction:(id)sender
{
    self.actionViewVisibile = NO;
    [TabActionController launchInSafari:self.tab.url];
}

- (void)presentInReadability:(id)sender
{
    self.actionViewVisibile = NO;
    [TabActionController presentWithReadabilty:self.tab.url inViewContoller:[TabulatabsApp sharedInstance].navigationController];
}

- (void)setupActionView
{ 
    UIView* view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];

    pageThumbnailView = [[UIImageView alloc] initWithFrame:view.bounds];
    pageThumbnailView.contentMode = UIViewContentModeScaleToFill;
    [view addSubview:pageThumbnailView];

    [self.contentView insertSubview:view atIndex:0];
    actionView = view;
}

- (void)setupPrimaryView
{
    scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
    scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    scrollView.directionalLockEnabled = YES;
    
    [self.contentView addSubview:scrollView];
        
    CGRect contentViewBounds = self.bounds;
    contentViewBounds.origin.x = contentViewBounds.size.width;
    
    UIView *view = [[UIView alloc] initWithFrame:contentViewBounds];
    view.backgroundColor = [UIColor whiteColor];
    
    tableCellLeftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowLeft.png"]];
    [view addSubview:tableCellLeftShadowView];
    tableCellRightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowRight.png"]];
    [view addSubview:tableCellRightShadowView];

    labelView = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
    labelView.userInteractionEnabled = NO;
    labelView.automaticallyDetectLinks = NO;
    labelView.lineBreakMode = UILineBreakModeWordWrap;
    labelView.opaque = NO;
    labelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    [view addSubview:labelView];
    
    labelViewSelected = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
    labelViewSelected.userInteractionEnabled = NO;
    labelViewSelected.automaticallyDetectLinks = NO;
    labelViewSelected.lineBreakMode = UILineBreakModeWordWrap;
    [view addSubview:labelViewSelected];
    
    favIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [view addSubview:favIconView];
    
    [scrollView addSubview:view];

    primaryView = view;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupActionView];
        [self setupPrimaryView];
    }
    return self;    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    scrollView.frame = bounds;
    scrollView.contentSize = CGSizeMake(bounds.size.width * 2 - kTabChooserCellLabelRest - kTabChooserCellBackgroundCrack, bounds.size.height);
    CGRect contentViewBounds = self.bounds;
    contentViewBounds.origin.x = contentViewBounds.size.width - kTabChooserCellLabelRest;
    contentViewBounds.size.width -= kTabChooserCellBackgroundCrack;
    primaryView.frame = contentViewBounds;
    actionView.frame = bounds;
    
    tableCellLeftShadowView.frame = CGRectMake(-8.0, 0.0, 8.0, 72.0);
    tableCellRightShadowView.frame = CGRectMake(primaryView.bounds.size.width, 0.0, 8.0, 72.0);

    [self layoutPageThumbnail];
    
    CGRect iconBounds = CGRectMake(5.0, 5.0, 16, 16);
    [favIconView setFrame:iconBounds];
    
    CGRect labelBounds = CGRectMake(26.0, 4.0, contentViewBounds.size.width - 26.0 - 3.0, contentViewBounds.size.height - 4.0);
    [labelView setFrame:labelBounds];
    [labelViewSelected setFrame:labelBounds];
}



#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView;
{
    actionViewVisibile = (aScrollView.contentOffset.x != self.bounds.size.width);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self hideOtherCellsActionView];
}


#pragma mark Notifications

- (void)faviconDidChange:(NSNotification *)notification;
{
    NSLog(@"faviconDidChange");
    favIconView.image = tab.favIconImage;
}

- (void)pageThumbnailDidChange:(NSNotification *)notification;
{
    NSLog(@"pageThumbnailDidChange on Page %@", tab.shortDomain);
    pageThumbnailView.image = tab.pageThumbnailImage;
    
    [self layoutPageThumbnail];
}


#pragma mark Private Methods

- (void)layoutPageThumbnail;
{
    if (!pageThumbnailView.image) {
        pageThumbnailView.hidden = YES;
    } else {
        CGRect pageThumbnailFrame = self.bounds;
        pageThumbnailFrame.size.width = pageThumbnailFrame.size.height * (pageThumbnailView.image.size.width / pageThumbnailView.image.size.height);
        pageThumbnailView.frame = pageThumbnailFrame;    
        pageThumbnailView.hidden = NO;
    }
}

@end
