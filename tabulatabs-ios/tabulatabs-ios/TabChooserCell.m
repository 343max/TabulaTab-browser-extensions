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

@implementation TabChooserCell

@synthesize labelView, labelViewSelected, favIconView;

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
         [(CAGradientLayer *)self.layer setColors:[NSArray arrayWithObjects:
            objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0] CGColor]),
            objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.1] CGColor]),
            objc_unretainedObject([[UIColor colorWithWhite:0 alpha:0.4] CGColor]),
        nil]];
        
        [(CAGradientLayer *)self.layer setLocations:[NSArray arrayWithObjects:
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
        
        [self.contentView addSubview:self.labelView];
        
        self.labelViewSelected = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        self.labelViewSelected.userInteractionEnabled = NO;
        self.labelViewSelected.automaticallyDetectLinks = NO;
        self.labelViewSelected.lineBreakMode = UILineBreakModeWordWrap;
        [self.contentView addSubview:self.labelViewSelected];
        
        self.favIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.favIconView];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect bounds = self.contentView.bounds;
    
    CGRect iconBounds = CGRectMake(5.0, 5.0, 16, 16);
    [self.favIconView setFrame:iconBounds];
    
    CGRect labelBounds = CGRectMake(26, 2, bounds.size.width - 26 - 5, bounds.size.height - 8);
    [self.labelView setFrame:labelBounds];
    [self.labelViewSelected setFrame:labelBounds];
}

- (void)setTitle:(NSString *)title withSiteName:(NSString *)siteName withShortDomainName:(NSString *)shortDomainName
{
    NSString *secondaryLine = ([siteName isEqualToString:@""] ? shortDomainName : siteName);
    NSString *mainLine = title;
    
    secondaryLineRange = NSMakeRange(0, [secondaryLine length]);
    mainLineRange = NSMakeRange([secondaryLine length] + 1, [mainLine length]);
    
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
