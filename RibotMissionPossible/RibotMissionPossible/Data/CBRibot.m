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

-(UIColor *)colour
{
    return [self colorWithHexString:self.hexColourString];
}


-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



@end
