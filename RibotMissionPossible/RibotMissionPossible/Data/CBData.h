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


#define KEY_STUDIO_NUMBER @"addressNumber"
#define KEY_STUDIO_STREET @"street"
#define KEY_STUDIO_CITY @"city"
#define KEY_STUDIO_COUNTY @"county"
#define KEY_STUDIO_POSTCODE @"postcode"
#define KEY_STUDIO_COUNTRY @"country"
#define KEY_STUDIO_PHOTOS @"photos"


#define ERROR_CODE_IMAGE_DOWNLOAD_FAILED 101

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


/**
 * Once downloaded contains the team members of ribot
 */
@property (nonatomic,readonly) NSArray* teamMembers;

/**
 * Once downloaded contains the team member colours of ribot. Every member has one even if they dont have one in the API. Non existing hex codes will be automatically assigned a colour
 */
@property (nonatomic,readonly) NSArray* teamMemberColours;

/**
 * Once downloaded contains the team member images
 */
@property (nonatomic,strong) NSArray* ribotars;


/**
 * Begins download process of all team members
 */
-(void)downloadRibotTeamWithCompletionBlock:(RibotTeamDownloaded) completionBlock;

/**
 * Begins download of info about a specific team member. 
 * Also downloads the ribotar. If ribotar image fails to download the error code is equal to ERROR_CODE_IMAGE_DOWNLOAD_FAILED. iF this happens, we
 * will assume that the ribot member has no ribotar. In a production app this sort of assumption probably would be too good.....
 */
-(void)downloadRibotTeamMember:(NSString*)ribotId withCompletionBlock:(RibotTeamMemberDownloaded) completionBlock;

/**
 * Begins download of info about ribot HQ
 */
-(void)downloadRibotStudioWithCompletionBlock:(RibotDataDownloaded) completionBlock;

/**
 * Returns the url to the ribotar for the specified ribot
 */
-(NSURL*)localUrlForRibotarForRibot:(CBRibot*)ribot;




@end
