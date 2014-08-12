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

@class CBData;

#pragma mark -
#pragma mark Block definitions

/**
 * Block define for callers to respond to download of a team members data
 */
typedef void (^RibotTeamMemberDownloaded)(CBRibot* ribot,NSError* error);

/**
 * Block define for callers to respond to download of all team members
 */
typedef void (^RibotTeamDownloaded)(NSError* error);


/**
 * Block define for callers to respond to download completion
 */
typedef void (^RibotDataDownloaded)(id result,NSError* error);



#pragma mark -
#pragma mark CBData Interface


/**
 * Responsible for all data retrieval
 */
@interface CBData : NSObject

/**
 * Returns a shared instance
 */
+ (instancetype)sharedInstance;


@property (nonatomic,readonly) NSArray* teamMembers;

/**
 * Begins download process of all team members
 */
-(void)downloadRibotTeamWithCompletionBlock:(RibotTeamDownloaded) completionBlock;

/**
 * Begins download of info about a specific team member
 */
-(void)downloadRibotTeamMember:(NSString*)ribotId withCompletionBlock:(RibotTeamMemberDownloaded) completionBlock;

/**
 * Begins download of info about ribot HQ
 */
-(void)downloadRibotStudioWithCompletionBlock:(RibotDataDownloaded) completionBlock;






@end
