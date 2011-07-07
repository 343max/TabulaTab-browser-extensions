//
//  MWTimedBlock.h
//  tabulatabs-ios
//
//  Created by Max Winde on 06.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWTimedBlock : NSObject
{
    void(^timerFireBlock)();
}
- (id)initWithTimout:(NSTimeInterval)timeout completionBlock:(void (^)())completionBlock;

@end
