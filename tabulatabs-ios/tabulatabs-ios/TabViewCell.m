//
//  TabChooserCell.m
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TabulatabsApp.h"
#import "TabListViewController.h"

#import "TabViewCell.h"



const CGFloat kTabChooserCellBackgroundCrack = 60.0;
const CGFloat kTabChooserCellLabelRest = 80.0;



@interface TabViewCell () {
@private
    UIScrollView *scrollView;

    UIView *primaryView;
    UIView *backgroundView;

    UIImageView *tableCellLeftShadowView;
    UIImageView *tableCellRightShadowView;
    UIButton *showPageButton;
    
    
    NSURL *pageThumbnailURL;
    UIImageView *pageThumbnailView;
    NSURL *favIconURL;
    UIImageView *favIconView;
    UILabel *siteNameLabel;
    UILabel *articleTitleLabel;
}

- (void)openPageButtonTaped:(id)sender;
- (void)faviconDidChange:(NSNotification *)notification;
- (void)pageThumbnailDidChange:(NSNotification *)notification;
- (void)layoutPageThumbnail;
- (void)setupBackgroundView;
- (void)setupPrimaryView;

@end




@implementation TabViewCell

@synthesize tab;
@synthesize backgroundViewVisible;
@synthesize markedAsRead;

- (void)setTab:(TTTab *)aTab;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabFavIconChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabPageThumbnailChangedNotification object:nil];
    
    tab = aTab;
    
    [tab loadImages];
    
    siteNameLabel.text = ([tab.siteTitle isEqualToString:@""] ? tab.shortDomain : tab.siteTitle);
    articleTitleLabel.text = tab.title;
        
    favIconView.image = tab.favIconImage;
    pageThumbnailView.image = tab.pageThumbnailImage;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faviconDidChange: ) name:TTTabFavIconChangedNotification object:tab];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageThumbnailDidChange:) name:TTTabPageThumbnailChangedNotification object:tab];
    
    [self setNeedsLayout];
}

- (void)setBackgroundViewVisible:(BOOL)visible animated:(BOOL)animated;
{
    backgroundViewVisible = visible;
    
    CGPoint contentOffset = CGPointMake(0.0, 0.0);
    if (!visible) {
        contentOffset.x = self.bounds.size.width - kTabChooserCellBackgroundCrack - kTabChooserCellLabelRest;
    }

    [scrollView setContentOffset:contentOffset animated:animated];
}

- (void)setBackgroundViewVisible:(BOOL)aActionViewVisibile;
{
    [self setBackgroundViewVisible:aActionViewVisibile animated:NO];
}

- (void)setMarkedAsRead:(BOOL)aMarkedAsRead;
{
    markedAsRead = aMarkedAsRead;
    
    if (markedAsRead) {
        siteNameLabel.alpha = 0.3;
        articleTitleLabel.alpha = 0.3;
        favIconView.alpha = 0.3;
        pageThumbnailView.alpha = 0.3;
        tableCellLeftShadowView.alpha = 0.3;
        tableCellRightShadowView.alpha = 0.3;
    } else {
        siteNameLabel.alpha = 1.0;
        articleTitleLabel.alpha = 1.0;
        favIconView.alpha = 1.0;
        pageThumbnailView.alpha = 1.0;
        tableCellLeftShadowView.alpha = 1.0;
        tableCellRightShadowView.alpha = 1.0;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



#pragma mark Lifecycle


- (void)prepareForReuse;
{
    [super prepareForReuse];
    self.backgroundViewVisible = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabFavIconChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabPageThumbnailChangedNotification object:nil];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabFavIconChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTTabPageThumbnailChangedNotification object:nil];
}

- (UIViewController *)viewController;
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)openPageButtonTaped:(id)sender;
{
    id viewController = [self viewController];
    [viewController openPage:tab];
}

- (void)hideOtherCellsActionView
{
    NSAssert(self.superview != nil, @"SuperView of TableCell set");
    
    UITableView *tableview = (UITableView *)self.superview;
    
    [tableview.visibleCells enumerateObjectsUsingBlock:^(TabViewCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell != self) {
            [cell setBackgroundViewVisible:NO animated:YES];
        }
    }];
}

- (void)setupBackgroundView;
{ 
    UIView* view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];

    pageThumbnailView = [[UIImageView alloc] initWithFrame:view.bounds];
    pageThumbnailView.contentMode = UIViewContentModeScaleToFill;
    [view addSubview:pageThumbnailView];

    [self.contentView insertSubview:view atIndex:0];
    backgroundView = view;
}

- (void)setupPrimaryView;
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
    
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    openButton.frame = view.bounds;
    openButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [openButton addTarget:self action:@selector(openPageButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:openButton];

    tableCellLeftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowLeft.png"]];
    [view addSubview:tableCellLeftShadowView];
    tableCellRightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowRight.png"]];
    [view addSubview:tableCellRightShadowView];
    
    siteNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    siteNameLabel.textColor = [UIColor darkGrayColor];
    siteNameLabel.font = [UIFont fontWithName:@"Palatino" size:12.0];
    [view addSubview:siteNameLabel];
    
    articleTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    articleTitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    articleTitleLabel.numberOfLines = 0;
    articleTitleLabel.font = [UIFont fontWithName:@"Palatino" size:16.0];
    [view addSubview:articleTitleLabel];
    
    favIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    favIconView.backgroundColor = [UIColor whiteColor];
    [view addSubview:favIconView];
        
    [scrollView addSubview:view];

    primaryView = view;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupBackgroundView];
        [self setupPrimaryView];
    }
    return self;    
}

- (void)layoutSubviews
{
    self.backgroundViewVisible = self.backgroundViewVisible;
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    scrollView.frame = bounds;
    scrollView.contentSize = CGSizeMake(bounds.size.width * 2 - kTabChooserCellLabelRest - kTabChooserCellBackgroundCrack, bounds.size.height);
    CGRect contentViewBounds = self.bounds;
    contentViewBounds.origin.x = contentViewBounds.size.width - kTabChooserCellLabelRest;
    contentViewBounds.size.width -= kTabChooserCellBackgroundCrack;
    primaryView.frame = contentViewBounds;
    backgroundView.frame = bounds;
    
    tableCellLeftShadowView.frame = CGRectMake(-8.0, 0.0, 8.0, 72.0);
    tableCellRightShadowView.frame = CGRectMake(primaryView.bounds.size.width, 0.0, 8.0, 72.0);

    [self layoutPageThumbnail];
    
    CGRect iconBounds = CGRectMake(5.0, 5.0, 16, 16);
    [favIconView setFrame:iconBounds];
    
    siteNameLabel.frame = CGRectMake(26.0, 6.0, contentViewBounds.size.width - 26.0 - 9.0, 16.0);
    articleTitleLabel.frame = CGRectMake(26.0, 22.0, contentViewBounds.size.width - 26.0 - 9.0, 40.0);
}



#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView;
{
    backgroundViewVisible = (aScrollView.contentOffset.x != self.bounds.size.width);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self hideOtherCellsActionView];
}


#pragma mark Notifications

- (void)faviconDidChange:(NSNotification *)notification;
{
    favIconView.image = tab.favIconImage;
}

- (void)pageThumbnailDidChange:(NSNotification *)notification;
{
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
