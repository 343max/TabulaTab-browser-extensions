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
}
@end

const CGFloat kTabChooserCellBackgroundCrack = 30.0;
const CGFloat kTabChooserCellLabelRest = 45.0;

@implementation TabChooserCell

@synthesize labelView, labelViewSelected, favIconView, primaryView, actionView, actionViewVisibile, browserTab;
@synthesize articleImageView;

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)prepareForReuse
{
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
    GradientView* view = [[GradientView alloc] initWithFrame:self.bounds];
    [self.contentView insertSubview:view atIndex:0];
    
//    view.layer.backgroundColor = [[UIColor colorWithRed:0.396 green:0.45 blue:0.56 alpha:1] CGColor];
//    
//    [(CAGradientLayer *)view.layer setColors:[NSArray arrayWithObjects:
//        objc_unretainedObject([[UIColor colorWithWhite:0 alpha:1] CGColor]),
//        objc_unretainedObject([[UIColor colorWithWhite:0 alpha:1] CGColor]),
//        objc_unretainedObject([[UIColor colorWithWhite:(float)21/255 alpha:1] CGColor]),
//        objc_unretainedObject([[UIColor colorWithWhite:(float)48/255 alpha:1] CGColor]),
//        nil]];
//    [(CAGradientLayer *)view.layer setLocations:[NSArray arrayWithObjects:
//                                                 [NSNumber numberWithFloat:0],
//                                                 [NSNumber numberWithFloat:0.5],
//                                                 [NSNumber numberWithFloat:0.5],
//                                                 [NSNumber numberWithFloat:1],
//        nil]];
    [(CAGradientLayer *)view.layer setColors:[NSArray arrayWithObjects:
                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.4] CGColor]),
                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.1] CGColor]),
                                              objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0] CGColor]),
                                              nil]];
    view.backgroundColor = [UIColor whiteColor];
    
    [(CAGradientLayer *)view.layer setLocations:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithFloat:0],
                                                 [NSNumber numberWithFloat:0.03],
                                                 [NSNumber numberWithFloat:0.4],
                                                 nil]];

    
    articleImageView = [[UIImageView alloc] initWithFrame:view.bounds];
    articleImageView.contentMode = UIViewContentModeScaleToFill;
    [view addSubview:articleImageView];
    
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
    
    [self.contentView addSubview:scrollView];
    
    CGRect contentViewBounds = self.bounds;
    contentViewBounds.origin.x = contentViewBounds.size.width;
    GradientView *view = [[GradientView alloc] initWithFrame:contentViewBounds];
    
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowOpacity = 0.9;
    view.layer.shadowRadius = 8.0;
    
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

    if (articleImageView.image) {
        CGRect articleImageFrame = bounds;
        articleImageFrame.size.width = articleImageFrame.size.height * (articleImageView.image.size.width / articleImageView.image.size.height);
        articleImageView.frame = articleImageFrame;
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
    [labelText setFont:[UIFont fontWithName:@"Baskerville" size:18.0] range:mainLineRange];
    [labelText setFont:[UIFont fontWithName:@"Baskerville" size:14.0] range:secondaryLineRange];
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

- (void)setArticleImage:(UIImage *)articleImage;
{
    articleImageView.image = articleImage;
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
