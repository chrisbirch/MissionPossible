//
//  CBRibot.m
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBRibot.h"

@implementation CBRibot

#pragma mark -
#pragma mark Initialisers 

-(id)initWithRibotJsonDict:(NSDictionary *)teamMemberDictionary
{
    if (self = [super init])
    {
        //store this, it will be used to return info about this person
        _ribotDictionary = teamMemberDictionary;
    }
    
    return self;
}

-(NSString *)ribotId
{
    return _ribotDictionary[KEY_RIBOT_ID];
}

-(NSString *)firstName
{
    return _ribotDictionary[KEY_RIBOT_FIRST_NAME];
}

-(NSString *)lastName
{
    return _ribotDictionary[KEY_RIBOT_LAST_NAME];
}

-(NSString *)nickName
{
    return _ribotDictionary[KEY_RIBOT_NICK_NAME];
}

-(NSString *)hexColourString
{
    return _ribotDictionary[KEY_RIBOT_HEX_COLOUR];
}

-(NSString *)role
{
    return _ribotDictionary[KEY_RIBOT_ROLE];
}

-(NSString *)ribotDescription
{
    return _ribotDictionary[KEY_RIBOT_DESCRIPTION];
}

-(NSString *)twitter
{
    return _ribotDictionary[KEY_RIBOT_TWITTER];
}

-(NSString *)favSweet
{
    return _ribotDictionary[KEY_RIBOT_FAV_SWEET];
}

-(NSString *)favSeason
{
    return _ribotDictionary[KEY_RIBOT_FAV_SEASON];
}

@end
