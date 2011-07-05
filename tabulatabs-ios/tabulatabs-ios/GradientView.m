//
//  GradientView.m
//  tabulatabs-ios
//
//  Created by Max Winde on 04.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
