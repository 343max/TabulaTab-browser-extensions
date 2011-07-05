//
//  TabBarLikeButton.m
//  tabulatabs-ios
//
//  Created by Max Winde on 05.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabBarLikeButton.h"

struct RGBA {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
};

#define BLUE_ALPHA_THRESHOLD 128
#define BLUE_BRIGHTNESS_ADJUST 30

@implementation TabBarLikeButton

- (UIImage *)grayTabBarItemFilterWithImage:(UIImage *)image
{
    int width = image.size.width, height = image.size.height;
    UIImage *result = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return result;
    }
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        CGColorSpaceRelease(colorSpace);
        return result;
    }
    CGFloat colors[8] = {80/255.0,80/255.0,80/255.0,1, 175/255.0,175/255.0,175/255.0,1};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,-(32-height)/2.0), CGPointMake(0,height+(32-height)/2.0), 0);
    CGGradientRelease(gradient);
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, CGRectMake(0,0,width,height), image.CGImage);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    if (newImage != NULL) {
        result = [UIImage imageWithCGImage:newImage];
        CGImageRelease(newImage);
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return result;
}

- (UIImage *)blueTabBarItemFilterWithImage:(UIImage *)image {
    int width = image.size.width,
    height = image.size.height;
    UIImage *result = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        return result;
    }
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        CGColorSpaceRelease(colorSpace);
        return result;
    }
    UIImage *gradient = [UIImage imageNamed:@"TabBarLikeButton.png"];
    CGContextDrawImage(context, CGRectMake(-(gradient.size.width - width) / 2.0, -(gradient.size.height - height) / 2.0, gradient.size.width, gradient.size.height), gradient.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, CGRectMake(0,0,width,height), image.CGImage);
    struct RGBA *pixels = CGBitmapContextGetData(context);
    if (pixels != NULL) {
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                int offset = x+y*width;
                if (pixels[offset].alpha >= BLUE_ALPHA_THRESHOLD && 
                    ((x == 0 || x == width-1 || y == 0 || y == height-1) ||
                     (pixels[x+(y-1)*width].alpha < BLUE_ALPHA_THRESHOLD) ||
                     (pixels[x+1+y*width].alpha < BLUE_ALPHA_THRESHOLD) ||
                     (pixels[x+(y+1)*width].alpha < BLUE_ALPHA_THRESHOLD) ||
                     (pixels[x-1+y*width].alpha < BLUE_ALPHA_THRESHOLD))) {
                        pixels[offset].red = MIN(pixels[offset].red + BLUE_BRIGHTNESS_ADJUST,255);
                        pixels[offset].green = MIN(pixels[offset].green + BLUE_BRIGHTNESS_ADJUST,255);
                        pixels[offset].blue = MIN(pixels[offset].blue + BLUE_BRIGHTNESS_ADJUST,255);
                    }
            }
        }
        CGImageRef image = CGBitmapContextCreateImage(context);
        if (image != NULL) {
            result = [UIImage imageWithCGImage:image];
            CGImageRelease(image);
        }
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return result;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    
    if (self) {
        [self setImage:[self grayTabBarItemFilterWithImage:image] forState:UIControlStateNormal];
        [self setImage:[self blueTabBarItemFilterWithImage:image] forState:UIControlStateHighlighted];
    }
    
    return self;
}

@end
