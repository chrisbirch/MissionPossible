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

- (id)initTestRibot
{
    if (self = [super init])
    {
        _ribotDictionary = nil;
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
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_NICK_NAME])
        return _ribotDictionary[KEY_RIBOT_NICK_NAME];
    else
    {
        return @"";
    }
}

-(NSString *)hexColourString
{
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_HEX_COLOUR])
        return _ribotDictionary[KEY_RIBOT_HEX_COLOUR];
    else
    {
        return @"#A0A0A0";
    }
}

-(NSString *)role
{
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_ROLE])
        return _ribotDictionary[KEY_RIBOT_ROLE];
    else
        return @"";
}

-(NSString *)ribotDescription
{
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_DESCRIPTION])
        return _ribotDictionary[KEY_RIBOT_DESCRIPTION];
    else
        return @"";
}

-(NSString *)twitter
{
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_TWITTER])
        return _ribotDictionary[KEY_RIBOT_TWITTER];
    else
        return @"";
}

-(NSString *)favSweet
{
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_FAV_SWEET])
        return _ribotDictionary[KEY_RIBOT_FAV_SWEET];
    else
        return @"";
}

-(NSString *)favSeason
{
    if ([_ribotDictionary.allKeys containsObject:KEY_RIBOT_FAV_SEASON])
         return _ribotDictionary[KEY_RIBOT_FAV_SEASON];
    else
        return @"";
}

-(NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@",_ribotDictionary];
}
@end
