//
//  CBRoundedImageHelper.h
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RoundedImageBatchDone)(NSDictionary* roundedImages);

@interface CBRoundedImageHelper : NSObject



/**
 * Creates rounded stroked ribots
 */
+(UIImage*)roundedImageFromImage:(UIImage*)image withOutputSize:(CGSize)size andStrokeColour:(UIColor*)colour andStrokeWidth:(CGFloat)strokeWidth;

/**
 * Creates rounded stroked ribots on a seperate thread and returns the result in a completion block
 */
+(void)roundedImagesOnDiskWithPaths:(NSDictionary *)images withOutputSize:(CGSize)size andStrokeColours:(NSDictionary *)colours andStrokeWidth:(CGFloat)strokeWidth andCompletionBlock:(RoundedImageBatchDone)completionBlock;


@end
