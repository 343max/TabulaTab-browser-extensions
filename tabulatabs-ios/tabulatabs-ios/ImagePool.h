//
//  ImagePool.h
//  tabulatabs-ios
//
//  Created by Max Winde on 30.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImagePool : NSObject

@property (readonly, strong) NSMutableDictionary *pool;

- (void)fetchImageToPool:(NSURLRequest *)imageUrlRequest imageLoadedBlock:(void(^)(UIImage *imageData))imageLoadedBlock;

@end
