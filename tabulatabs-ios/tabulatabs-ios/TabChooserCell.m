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
#import <QuartzCore/CAGradientLayer.h>
#import "GradientView.h"
#import "TabBarLikeButton.h"
#import "MWTimedBlock.h"
#import "TabActionController.h"

@implementation TabChooserCell

@synthesize labelView, labelViewSelected, favIconView, primaryView, actionView, actionViewVisibile, browserTab;

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)prepareForReuse
{
    self.actionViewVisibile = NO;
}

- (void)showActionView
{
    self.actionView.hidden = NO;    

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseOut animations:^(void) {
        self.primaryView.layer.position = CGPointMake(self.primaryView.layer.position.x + self.frame.size.width, self.primaryView.layer.position.y);
    } completion:nil];
    
    float frameWidth = self.frame.size.width;
    
    [actionButtons enumerateObjectsUsingBlock:^(TabBarLikeButton *button, NSUInteger idx, BOOL *stop) {
        button.layer.opacity = 0;
        CGPoint endPosition = button.layer.position;
        CGPoint startPosition = CGPointMake(endPosition.x - frameWidth, endPosition.y);
        button.layer.position = startPosition;
        
        [UIView animateWithDuration:0.2 delay:(actionButtons.count - idx) * 0.07  options:UIViewAnimationCurveEaseOut animations:^(void) {
            button.layer.opacity = 1;
            button.layer.position = endPosition;
        } completion:nil];
    }];
}

- (void)hideActionView
{
    int multiplier = 1;
    
    [actionButtons enumerateObjectsUsingBlock:^(TabBarLikeButton *button, NSUInteger idx, BOOL *stop) {        
        [UIView animateWithDuration:0.1 * multiplier delay:(actionButtons.count - idx - 1) * 0.07 * multiplier  options:UIViewAnimationCurveEaseOut animations:^(void) {
            button.layer.opacity = 0;
            button.layer.contentsScale = 0.1;
        } completion:nil];
    }];    
    
    [UIView animateWithDuration:0.1 * multiplier delay:0.2 * multiplier options:0 animations:^(void) {
        self.primaryView.layer.position = CGPointMake(self.primaryView.layer.position.x - self.frame.size.width, self.primaryView.layer.position.y);
    } completion:nil];

    MWTimedBlock *timedBlock = [[MWTimedBlock alloc] initWithTimout:0.2 completionBlock:^(void) {
        self.actionView.hidden = YES;
    }];
}

- (void)setActionViewVisible:(BOOL)visible
{
    
    if (actionViewVisibile == visible) {
        return;
    }
    
    actionViewVisibile = visible;
    
    if (visible) {
        [self showActionView];
    } else {
        [self hideActionView];
    }
}

- (void)hideOtherCellsActionView
{
    NSAssert(self.superview != nil, @"SuperView of TableCell set");
    
    UITableView *tableview = (UITableView *)self.superview;
    
    [tableview.visibleCells enumerateObjectsUsingBlock:^(TabChooserCell *cell, NSUInteger idx, BOOL *stop) {
        if (cell != self) {
            cell.actionViewVisibile = NO;
        }
    }];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGesture
{
    [self hideOtherCellsActionView];
    self.actionViewVisibile = YES;
}

- (void)launchSafariAction:(id)sender
{
    self.actionViewVisibile = NO;
    [TabActionController launchInSafari:self.browserTab];
}

- (void)setupActionView
{    
    GradientView* view = [[GradientView alloc] initWithFrame:self.frame];
    [self.contentView insertSubview:view atIndex:0];
    
    view.layer.backgroundColor = [[UIColor colorWithRed:0.396 green:0.45 blue:0.56 alpha:1] CGColor];
    
    [(CAGradientLayer *)view.layer setColors:[NSArray arrayWithObjects:
        objc_unretainedObject([[UIColor colorWithWhite:0 alpha:1] CGColor]),
        objc_unretainedObject([[UIColor colorWithWhite:0 alpha:1] CGColor]),
        objc_unretainedObject([[UIColor colorWithWhite:(float)21/255 alpha:1] CGColor]),
        objc_unretainedObject([[UIColor colorWithWhite:(float)48/255 alpha:1] CGColor]),
        nil]];
    [(CAGradientLayer *)view.layer setLocations:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithFloat:0],
                                                 [NSNumber numberWithFloat:0.5],
                                                 [NSNumber numberWithFloat:0.5],
                                                 [NSNumber numberWithFloat:1],
        nil]];
    
    TabBarLikeButton *safariButton = [[TabBarLikeButton alloc] initWithImage:[UIImage imageNamed:@"Compass.png"]];
    [safariButton addTarget:self action:@selector(launchSafariAction:) forControlEvents:UIControlEventTouchUpInside];
    TabBarLikeButton *readabilityButton = [[TabBarLikeButton alloc] initWithImage:[UIImage imageNamed:@"164-glasses-2.png"]];
    TabBarLikeButton *closeTabButton = [[TabBarLikeButton alloc] initWithImage:[UIImage imageNamed:@"Circle-Check.png"]];
    
    actionButtons = [NSArray arrayWithObjects:safariButton, readabilityButton, closeTabButton, nil];
    
    [actionButtons enumerateObjectsUsingBlock:^(TabBarLikeButton *button, NSUInteger idx, BOOL *stop) {
        [view addSubview:button];
    }];
    
    view.hidden = YES;
        
    self.actionView = view;
}

- (void)setupPrimaryView
{
    GradientView *view = [[GradientView alloc] initWithFrame:self.frame];
    [self.contentView addSubview:view];
    
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
    
    self.primaryView = view;
}

- (void)setupGestures
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeGesture];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupActionView];
        [self setupPrimaryView];
        [self setupGestures];
    }
    return self;    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    self.primaryView.bounds = bounds;
    self.actionView.bounds = bounds;

    CGRect iconBounds = CGRectMake(5.0, 5.0, 16, 16);
    [self.favIconView setFrame:iconBounds];
    
    CGRect labelBounds = CGRectMake(26, 2, bounds.size.width - 26 - 5, bounds.size.height - 8);
    [self.labelView setFrame:labelBounds];
    [self.labelViewSelected setFrame:labelBounds];
    
    float buttonWidth = self.frame.size.height;
    int buttonCount = actionButtons.count;
    float buttonDistance = (self.frame.size.width - buttonWidth * buttonCount) / (buttonCount + 1);
    
    CGRect emptyButtonFrame = CGRectMake(buttonDistance, 0, buttonWidth, buttonWidth);
    
    [actionButtons enumerateObjectsUsingBlock:^(TabBarLikeButton *button, NSUInteger idx, BOOL *stop) {
        CGRect buttonFrame = emptyButtonFrame;
        buttonFrame.origin.x = buttonFrame.origin.x + (buttonDistance + buttonWidth) * idx;
        button.frame = buttonFrame;
    }];
}

- (void)setTitle:(NSString *)title withSiteName:(NSString *)siteName withShortDomainName:(NSString *)shortDomainName
{
    NSString *secondaryLine = ([siteName isEqualToString:@""] ? shortDomainName : siteName);
    NSString *mainLine = title;
    
    NSRange secondaryLineRange = NSMakeRange(0, [secondaryLine length]);
    NSRange mainLineRange = NSMakeRange([secondaryLine length] + 1, [mainLine length]);
    
    NSMutableAttributedString *labelText = [NSMutableAttributedString attributedStringWithString:[NSString stringWithFormat:@"%@\n%@", secondaryLine, mainLine]];
    [labelText setTextColor:[UIColor darkGrayColor] range:secondaryLineRange];
    [labelText setFont:[UIFont boldSystemFontOfSize:14.0] range:mainLineRange];
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

@end