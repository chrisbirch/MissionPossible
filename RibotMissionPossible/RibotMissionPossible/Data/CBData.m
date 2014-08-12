//
//  CBData.m
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//
#import "CBData.h"

#define BASE_URL @"https://devchallenge.ribot.io/api"

#define KEY_RESPONSE_ERROR @"error"


@interface CBData ()
{
    NSMutableArray* _teamMembers;
}


/**
 * Holds the number of team members left to download.
 */
@property(nonatomic,assign) NSUInteger ribotsToDownload;



@end

@implementation CBData


#pragma mark -
#pragma mark Initialisers

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^ { shared = [[self alloc] init]; });
    return shared;
}

-(id)init
{
    if (self = [super init])
    {
     
    }
    
    return self;
}

-(NSArray *)teamMembers
{
    @synchronized(_teamMembers)
    {
        return _teamMembers;
    }
}

-(void)downloadDataFromUrl:(NSString*)urlString withCompletionBlock:(RibotDataDownloaded)completionBlock
{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSession* session = [NSURLSession sharedSession];

    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              NSError* e = nil;
              
              //Attempt to deserialize the ribot data
              id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
              
              //Make sure there was no error decoding the json
              if (!e)
              {
                  if ([obj isKindOfClass:[NSDictionary class]])
                  {
                      NSDictionary* dictionary = (NSDictionary*)obj;
                      
                      if ([dictionary.allKeys containsObject:KEY_RESPONSE_ERROR])
                      {
                          //Create error from information provided by server
                          e = [[NSError alloc] initWithDomain:dictionary[KEY_RESPONSE_ERROR] code:1 userInfo:nil];

                          //only pass error back to caller
                          obj = nil;
                      }
                  }
                  else if (![obj isKindOfClass:[NSArray class]])
                  {
                      obj = nil;
                      //Dont know what this object is!
                      e = [[NSError alloc] initWithDomain:@"No idea what this is!" code:2 userInfo:nil];
                  }
              }
              
              completionBlock(obj,e);
          }
          else
          {
              //Something went wrong with the download
              completionBlock(nil,error);
          }
      }];
    
    //start the task
    [task resume];
    
}

#pragma mark -
#pragma mark Download


-(void)downloadRibotTeamMember:(NSString *)ribotId withCompletionBlock:(RibotTeamMemberDownloaded)completionBlock
{
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@/team/%@", BASE_URL, ribotId];
    
    [self downloadDataFromUrl:urlString withCompletionBlock:^(NSDictionary *result, NSError *error)
    {
        //Create Ribot from this dictionary
        
        if (!error)
        {
            CBRibot* ribot = [[CBRibot alloc] initWithRibotJsonDict:result];
            //pass to calling code
            completionBlock(ribot,nil);
        }
        else
        {
            completionBlock(nil,error);
        }
    }];
}

-(void)downloadRibotTeamWithCompletionBlock:(RibotTeamDownloaded)completionBlock
{
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@/team", BASE_URL];

    //create a new array to hold our team
    _teamMembers = [NSMutableArray new];
    
    __block CBData* this = self;
    __block NSMutableArray* teamMembers = _teamMembers;
    
    [self downloadDataFromUrl:urlString withCompletionBlock:^(NSArray *allTeamMembers, NSError *error)
     {
         //Loop through all team members
         
         if (!error)
         {
             //remember the amount we have to download
             this.ribotsToDownload = allTeamMembers.count;
             
             for(NSDictionary* teamMember in allTeamMembers)
             {
                 if ([teamMember.allKeys containsObject:KEY_RIBOT_ID])
                 {
                     NSString* ribotId = teamMember[KEY_RIBOT_ID];
                     
                     //Now download all the information we have for this member
                     [this downloadRibotTeamMember:ribotId withCompletionBlock:^(CBRibot *ribot, NSError *error) {
                         
                         @synchronized(teamMembers)
                         {
                             [teamMembers addObject:ribot];
                             
                             //decrement the ribot count and check if we've finished
                             NSUInteger ribotsLeft = --this.ribotsToDownload;
                             
                             if(!ribotsLeft)
                             {
                                 //inform calling code that we're done
                                 completionBlock(nil);
                             }
                         }
                     }];
                 }
                 else
                 {
                     //Create error from information provided by server
                     NSError* e = [[NSError alloc] initWithDomain:@"Unknown data format" code:3 userInfo:nil];

                     completionBlock(e);
                     
                     break;
                 }
             }
             
         }
         else
         {
             completionBlock(error);
         }
     }];

}



@end
