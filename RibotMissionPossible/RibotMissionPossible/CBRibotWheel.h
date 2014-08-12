//
//  CBRibotWheel.h
//  RibotMissionPossible
//
//  Created by chris on 13/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBRibotWheel : NSObject

@property (nonatomic,copy) NSArray* teamMembers;

-(UIImage*)drawWheelImageOfSize:(CGSize)size;

@end
