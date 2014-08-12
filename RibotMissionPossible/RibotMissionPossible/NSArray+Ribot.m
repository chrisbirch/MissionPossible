//
//  NSArray+Ribot.m
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "NSArray+Ribot.h"

#import "CBRibot.h"


@implementation NSArray (Ribot)


-(CBRibot *)ribotWithId:(NSString *)ribotId
{
    for (CBRibot* ribot in self)
    {
        if ([ribot.ribotId isEqualToString:ribotId])
            return ribot;
    }
    
    return nil;
}


@end
