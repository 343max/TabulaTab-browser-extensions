//
//  ImagePool.m
//  tabulatabs-ios
//
//  Created by Max Winde on 30.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWImagePool.h"
#import "MWURLConnection.h"

@interface MWImagePool () {
@private
    NSMutableDictionary *pool;
    NSUInteger connectionCount;
    NSMutableArray *queuedRequests;
}

- (void)start;

@end


@implementation MWImagePool

- (id)init
{
    self = [super init];
    if (self) {
        pool = [[NSMutableDictionary alloc] init];
        queuedRequests = [[NSMutableArray alloc] init];
        connectionCount = 0;
    }
    
    return self;
}

- (void)start;
{
    if (connectionCount < 5 & queuedRequests.count > 0) {
        MWURLConnection *connection = [queuedRequests objectAtIndex:0];
        [queuedRequests removeObject:connection];
        [connection start];
        connectionCount++;
    }

    if (connectionCount < 5 & queuedRequests.count > 0) {
        [self performSelector:@selector(start) withObject:self afterDelay:0.1];
    }
}

- (void)processCompleted;
{
    connectionCount--;
    [self start];
}

- (void)fetchImageToPool:(NSURLRequest *)imageUrlRequest imageLoadedBlock:(void(^)(UIImage *imageData))imageLoadedBlock
{
    NSString *urlString = imageUrlRequest.URL.absoluteString;
    
    UIImage *imageData = [pool objectForKey:urlString];
    
    if (imageData) {
        imageLoadedBlock(imageData);
    } else {
        __block MWImagePool *blockSelf = self;
        
        MWURLConnection *connection = [[MWURLConnection alloc] initWithRequest:imageUrlRequest];
        [connection setDidFinishLoadingBlock:^(NSData *data) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image) {
                [pool setObject:image forKey:urlString];
                imageLoadedBlock(image);
            }
            [blockSelf processCompleted];
        }];
        
        [queuedRequests addObject:connection];
        [self performSelector:@selector(start) withObject:self afterDelay:0.1];
    }
}

@end