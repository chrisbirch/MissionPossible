//
//  CBRoundedImageHelper.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBRoundedImageHelper.h"

@implementation CBRoundedImageHelper


+(UIImage*)roundedImageFromImage:(UIImage*)image withOutputSize:(CGSize)size andStrokeColour:(UIColor*)colour andStrokeWidth:(CGFloat)strokeWidth
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect cRect =CGRectMake(0, 0, size.width, size.height);
    
    //Create the circle
    CGContextAddEllipseInRect(context, cRect);
    //And use it for the clipping
    CGContextClip(context);
    //clip the context
    CGContextClearRect(context, cRect);
    
    //Now draw the image in the clipping rect
    [image drawInRect:CGRectMake(cRect.origin.x, cRect.origin.y, cRect.size.width, cRect.size.height)];
    
    CGContextSetStrokeColorWithColor(context, colour.CGColor);
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextStrokeEllipseInRect(context, cRect);
    
    UIImage* output = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return output;
    
}

+(void)roundedImagesOnDiskWithPaths:(NSDictionary *)images withOutputSize:(CGSize)size andStrokeColours:(NSDictionary *)colours andStrokeWidth:(CGFloat)strokeWidth andCompletionBlock:(RoundedImageBatchDone)completionBlock
{
    
    //Start an activity indicator here
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        //Round the images on the background thread
        
        NSMutableDictionary* roundedImages = [NSMutableDictionary new];

        
        for (NSString*key in images.allKeys)
        {
            NSString* imagePath = images[key];
            
            UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
            UIColor* thisColour = colours[key];
            UIImage* rounded = [CBRoundedImageHelper roundedImageFromImage:image withOutputSize:size andStrokeColour:thisColour andStrokeWidth:strokeWidth];
            
            if (rounded)
            {
                [roundedImages setObject:rounded forKey:key];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Alert code we've finished rounding the images
            completionBlock(roundedImages);
            
        });
    });
}
@end
