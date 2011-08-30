//
//  TabChooserCell.m
//  tabulatabs-ios
//
//  Created by Max Winde on 29.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabChooserCell.h"
#import "NSAttributedString+Attributes.h"
#import "TabulatabsApp.h"
#import <QuartzCore/QuartzCore.h>
#import "GradientView.h"
#import "TabBarLikeButton.h"
#import "MWTimedBlock.h"
#import "TabActionController.h"

@interface TabChooserCell () {
@private
    UIScrollView *scrollView;
    UIImageView *tableCellLeftShadowView;
    UIImageView *tableCellRightShadowView;
    UIImageView *thumbnailRightShadowView;
    UIButton *showPageButton;
}
@end

const CGFloat kTabChooserCellBackgroundCrack = 60.0;
const CGFloat kTabChooserCellLabelRest = 80.0;

@implementation TabChooserCell

@synthesize pageThumbnailURL;
@synthesize favIconURL;
@synthesize labelView, labelViewSelected, favIconView, primaryView, actionView, actionViewVisibile, browserTab;
@synthesize pageThumbnailView;

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.actionViewVisibile = NO;
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
    [TabActionController launchInSafari:self.browserTab.url];
}

- (void)presentInReadability:(id)sender
{
    self.actionViewVisibile = NO;
    [TabActionController presentWithReadabilty:self.browserTab.url inViewContoller:[TabulatabsApp sharedInstance].navigationController];
}

- (void)setupActionView
{ 
//    GradientView* view = [[GradientView alloc] initWithFrame:self.bounds];
//    
//    [(CAGradientLayer *)view.layer setColors:[NSArray arrayWithObjects:
//                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.4] CGColor]),
//                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.1] CGColor]),
//                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0] CGColor]),
//                                              nil]];
//    view.backgroundColor = [UIColor whiteColor];
//    
//    [(CAGradientLayer *)view.layer setLocations:[NSArray arrayWithObjects:
//                                                 [NSNumber numberWithFloat:0],
//                                                 [NSNumber numberWithFloat:0.03],
//                                                 [NSNumber numberWithFloat:0.4],
//                                                 nil]];
    UIView* view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:235.0 / 255.0 blue:1.0 alpha:1.0];

    pageThumbnailView = [[UIImageView alloc] initWithFrame:view.bounds];
    pageThumbnailView.contentMode = UIViewContentModeScaleToFill;
    [view addSubview:pageThumbnailView];
    
    thumbnailRightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowRight.png"]];
    thumbnailRightShadowView.alpha = 0.7;
    [view addSubview:thumbnailRightShadowView];

    [self.contentView insertSubview:view atIndex:0];
    self.actionView = view;
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
    GradientView *view = [[GradientView alloc] initWithFrame:contentViewBounds];
    
    [(CAGradientLayer *)view.layer setColors:[NSArray arrayWithObjects:
                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0] CGColor]),
                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.1] CGColor]),
                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.4] CGColor]),
                                              nil]];
    view.backgroundColor = [UIColor whiteColor];
    
    [(CAGradientLayer *)view.layer setLocations:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithFloat:0.6],
                                                 [NSNumber numberWithFloat:0.97],
                                                 [NSNumber numberWithFloat:1],
                                                 nil]];
    
    tableCellLeftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowLeft.png"]];
    [view addSubview:tableCellLeftShadowView];
    tableCellRightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellShadowRight.png"]];
    [view addSubview:tableCellRightShadowView];

    self.labelView = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
    self.labelView.userInteractionEnabled = NO;
    self.labelView.automaticallyDetectLinks = NO;
    self.labelView.lineBreakMode = UILineBreakModeWordWrap;
    self.labelView.opaque = NO;
    self.labelView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    [view addSubview:self.labelView];
    
    self.labelViewSelected = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
    self.labelViewSelected.userInteractionEnabled = NO;
    self.labelViewSelected.automaticallyDetectLinks = NO;
    self.labelViewSelected.lineBreakMode = UILineBreakModeWordWrap;
    [view addSubview:self.labelViewSelected];
    
    self.favIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [view addSubview:self.favIconView];
    
    [scrollView addSubview:view];

    self.primaryView = view;
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
    self.primaryView.frame = contentViewBounds;
    self.actionView.frame = bounds;
    
    tableCellLeftShadowView.frame = CGRectMake(-8.0, 0.0, 8.0, 72.0);
    tableCellRightShadowView.frame = CGRectMake(self.primaryView.bounds.size.width,0.0, 8.0, 72.0);

    if (!pageThumbnailView.image) {
        pageThumbnailView.hidden = YES;
        thumbnailRightShadowView.hidden = YES;
    } else {
        CGRect pageThumbnailFrame = bounds;
        pageThumbnailFrame.size.width = pageThumbnailFrame.size.height * (pageThumbnailView.image.size.width / pageThumbnailView.image.size.height);
        pageThumbnailView.frame = pageThumbnailFrame;
        thumbnailRightShadowView.frame = CGRectMake(pageThumbnailFrame.size.width, 0.0, 8.0, 72.0);

        pageThumbnailView.hidden = NO;
        thumbnailRightShadowView.hidden = NO;
    }

    CGRect iconBounds = CGRectMake(7.0, 7.0, 16, 16);
    [self.favIconView setFrame:iconBounds];
    
    CGRect labelBounds = CGRectMake(30.0, 7.0, contentViewBounds.size.width - 30.0 - 5, contentViewBounds.size.height - 8);
    [self.labelView setFrame:labelBounds];
    [self.labelViewSelected setFrame:labelBounds];
}

- (void)setTitle:(NSString *)title withSiteName:(NSString *)siteName withShortDomainName:(NSString *)shortDomainName
{
    NSString *secondaryLine = ([siteName isEqualToString:@""] ? shortDomainName : siteName);
    NSString *mainLine = title;
    
    NSRange secondaryLineRange = NSMakeRange(0, [secondaryLine length]);
    NSRange mainLineRange = NSMakeRange([secondaryLine length] + 1, [mainLine length]);
    
    NSMutableAttributedString *labelText = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@\n%@", secondaryLine, mainLine]];
    [labelText setTextColor:[UIColor darkGrayColor] range:secondaryLineRange];
    [labelText setFont:[UIFont fontWithName:@"Palatino-Bold" size:16.0] range:mainLineRange];
    [labelText setFont:[UIFont fontWithName:@"Palatino" size:12.0] range:secondaryLineRange];
    self.labelView.attributedText = labelText;
    
    NSMutableAttributedString *labelTextSelected = [NSMutableAttributedString attributedStringWithAttributedString:labelText];
    [labelTextSelected setTextColor:[UIColor whiteColor]];
    self.labelViewSelected.attributedText = labelTextSelected;
}

- (void)setFavIcon:(UIImage *)favIcon
{
    favIconView.image = favIcon;
    [favIconView setNeedsDisplay];
}

- (void)setPageThumbnail:(UIImage *)pageThumbnail;
{
    pageThumbnailView.image = pageThumbnail;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    self.labelView.hidden = highlighted;
    self.labelViewSelected.hidden = !highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.labelView.hidden = selected;
    self.labelViewSelected.hidden = !selected;
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

@end
