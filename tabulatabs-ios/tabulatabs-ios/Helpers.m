//
//  Helpers.m
//  HomePwner
//
//  Created by Max Winde on 18.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "Helpers.h"

NSString *pathInDocumentDirectory(NSString *fileName)
{    
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

UIImage *scaleImageToMinSize(UIImage *image, CGSize size)
{
    float scaleFactor = MAX(size.width / [image size].width, size.height / [image size].height);
    
    if(scaleFactor >= 1) {
        scaleFactor = 1;
    }
    
    float width = [image size].width * scaleFactor;
    float height = [image size].height * scaleFactor;
    
    CGRect imageRect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(imageRect.size);
    
    [image drawInRect:imageRect];
    
    UIImage *scaledImage;
    
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}