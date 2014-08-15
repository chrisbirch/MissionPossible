//
//  CBRibot.h
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

/**
 * Represents an individual Ribot staff member.
 * Basically takes a dictionary as the backing store of simple readonly properties
 * Simplifies the process of working with the ribot
 */

#import <Foundation/Foundation.h>


//The following defines are the keys for the data we need in the api
//The first ones are used in both the list and specific team member api
#pragma mark -
#pragma mark Defines - Required Keys

#define KEY_RIBOT_ID @"id"
#define KEY_RIBOT_FIRST_NAME @"firstName"
#define KEY_RIBOT_LAST_NAME @"lastName"

#pragma mark -
#pragma mark Defines - Optional Keys

#define KEY_RIBOT_NICK_NAME @"nickName"
#define KEY_RIBOT_HEX_COLOUR @"hexColor"
#define KEY_RIBOT_ROLE @"role"

#pragma mark -
#pragma mark Defines - Optional Keys that appear only in the specifiec team member API

#define KEY_RIBOT_DESCRIPTION @"description"
#define KEY_RIBOT_TWITTER @"twitter"
#define KEY_RIBOT_FAV_SWEET @"favSweet"
#define KEY_RIBOT_FAV_SEASON @"favSeason"

//Use to simplify creating new keys
//#define KEY_RIBOT_<#NAME#> @"<#VALUE#>"


@interface CBRibot : NSObject

/**
 * Contains information about the ribot that was downloaded from the server
 */
@property (nonatomic,readonly,strong) NSDictionary* ribotDictionary;

/**
 * Inits a new instance by specifying the dictionary with that contains stuff about this particular ribot
 */
-(id)initWithRibotJsonDict:(NSDictionary*)teamMemberDictionary;


/**
 * Unique team member id
 */
@property (nonatomic,strong,readonly) NSString* ribotId;

/**
 * Persons first name
 */
@property (nonatomic,strong,readonly) NSString* firstName;
/**
 * Persons last name
 */
@property (nonatomic,strong,readonly) NSString* lastName;

/**
 *  A nickname the person likes to be called
 */
@property (nonatomic,strong,readonly) NSString* nickName;

/**
 * The persons unique ribot hex colour, prefixed with a # (
 */
@property (nonatomic,strong,readonly) NSString* hexColourString;

/**
 * The persons role at ribot
 */
@property (nonatomic,strong,readonly) NSString* role;

/**
 * A short description about the person
 */
@property (nonatomic,strong,readonly) NSString* ribotDescription;
/**
 * The persons twitter username
 */
@property (nonatomic,strong,readonly) NSString* twitter;
/**
 * The persons favourite sweet
 */
@property (nonatomic,strong,readonly) NSString* favSweet;

/**
 *  The persons favourite season of the year. Either spring, summer, autumn or winter
 */
@property (nonatomic,strong,readonly) NSString* favSeason;

/**
 * Has this ribot been unlocked by the game
 */
@property (nonatomic,assign) BOOL isUnlocked;



@end
