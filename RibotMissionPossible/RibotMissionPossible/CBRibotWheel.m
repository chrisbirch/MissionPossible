//
//  CBRibotWheel.m
//  RibotMissionPossible
//
//  Created by chris on 13/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBRibotWheel.h"

@implementation CBRibotWheel


-(UIImage*)drawWheelImageOfSize:(CGSize)size
{
    /*
        Uses the following for circle positioning algorithm: http://stackoverflow.com/a/15235425/1027452
     */
    
    UIImage* j = [UIImage imageNamed:@"jerome.jpg"];
    
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);

    CGContextRef context = UIGraphicsGetCurrentContext();

    //get midpoint of new image
    CGPoint point = CGPointMake(size.width/2.0f, size.height/2.0f);
    
    
    CGFloat cita = 0;
    CGFloat bigCircleRadius = point.x / 2.0;
    CGFloat smallCircleRadius = bigCircleRadius / 4.0;
    for (int i = 0; i < 8; i++) {
        
        CGPoint smallCircleCenter = CGPointMake(point.x  + bigCircleRadius * cos(cita) - smallCircleRadius/2.0 , point.y + bigCircleRadius * sin(cita) - smallCircleRadius / 2.0 );
        CGRect smallCircleRect = CGRectMake(smallCircleCenter.x,smallCircleCenter.y,smallCircleRadius,smallCircleRadius);
        
        [j drawInRect:smallCircleRect];
        
        
        CGContextAddEllipseInRect(context, smallCircleRect);
        CGContextStrokePath(context);
        cita += M_PI / 4.0;
    }

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
