//
//  NSArray+Ribot.h
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBRibot;

@interface NSArray (Ribot)


/**
 * Returns the ribot with the specified id.
 * This assumes that the current array is populated with Ribots
 */
-(CBRibot*)ribotWithId:(NSString*)ribotId;

@end
