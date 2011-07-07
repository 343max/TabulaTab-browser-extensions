//
//  MWTimedBlock.m
//  tabulatabs-ios
//
//  Created by Max Winde on 06.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWTimedBlock.h"

@implementation MWTimedBlock

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithTimout:(NSTimeInterval)timeout completionBlock:(void (^)())completionBlock
{
    self = [self init];
    
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:NO];
        timerFireBlock = completionBlock;
    }
    
    return self;
}

- (void)timerFireMethod:(NSTimer *)theTimer
{
    timerFireBlock();
}

@end
