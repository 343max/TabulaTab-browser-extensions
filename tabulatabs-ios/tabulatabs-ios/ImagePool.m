//
//  ImagePool.m
//  tabulatabs-ios
//
//  Created by Max Winde on 30.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagePool.h"
#import "MWURLConnection.h"

@implementation ImagePool

@synthesize pool;

- (id)init
{
    self = [super init];
    if (self) {
        pool = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)fetchImageToPool:(NSURLRequest *)imageUrlRequest imageLoadedBlock:(void(^)(UIImage *imageData))imageLoadedBlock
{
    NSString *urlString = imageUrlRequest.URL.absoluteString;
    
    UIImage *imageData = [pool objectForKey:urlString];
    
    if (imageData) {
        imageLoadedBlock(imageData);
    } else {
        MWURLConnection *connection = [[MWURLConnection alloc] initWithRequest:imageUrlRequest];
        [connection setDidFinishLoadingBlock:^(NSData *data) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image) {
                [pool setObject:image forKey:urlString];
                imageLoadedBlock(image);
            }
        }];
        [connection start];
    }
}

@end
