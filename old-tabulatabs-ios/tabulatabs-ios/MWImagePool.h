//
//  ImagePool.h
//  tabulatabs-ios
//
//  Created by Max Winde on 30.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWImagePool : NSObject

- (void)fetchImageToPool:(NSURLRequest *)imageUrlRequest imageLoadedBlock:(void(^)(UIImage *imageData))imageLoadedBlock;
- (void)processCompleted;

@end
