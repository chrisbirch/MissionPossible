//
//  CBData.h
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "CBData.h"
#import "CBRibot.h"


/**
 * Block define for callers to respond to download of a team members data
 */
typedef void (^RibotTeamMemberDownloaded)(CBData* caller, CBRibot* ribot);

/**
 * Block define for callers to respond to download completion
 */
typedef void (^RibotDataDownloaded)(CBData* caller);

/**
 * Responsible for all data retrieval
 */
@interface CBData : NSObject

/**
 * Begins download process of all team members
 */
-(void)downloadRibotTeamWithSuccessBlock:(RibotDataDownloaded) success;

/**
 * Begins download of info about a specific team member
 */
-(void)downloadRibotTeamMember:(NSString*)ribotId withSuccessBlock:(RibotTeamMemberDownloaded) success;

#pragma mark -
#pragma mark Retrieval from downloaded items

/**
 * Returns the ribot with the specified id
 */
-(CBRibot*)ribotWithId:(NSString*)ribotId;



@end
