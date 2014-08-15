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

/**
 * The key in the ns user defaults that holds the ribots that have been unlocked through the game
 */
#define USER_DEFAULTS_UNLOCKED_RIBOTS @"Unlocked"

/**
 * Block define for callers to respond to file download completion
 */
typedef void (^RibotFileDownloaded)(NSString* localFilename,NSError* error);

/**
 * Block define for callers to respond to image download
 */
typedef void (^RibotImageDownloaded)(CBRibot* ribot, NSString* localFilename,NSError* error);


@interface CBData ()
{
    NSMutableArray* _teamMembers;
    /**
     * Holds the ribot id's of those team members we have "unlocked" through playing the game
     */
    NSMutableArray* unlockedRibots;
}


/**
 * Holds the number of team members left to download.
 */
@property(nonatomic,assign) NSUInteger ribotsToDownload;


/**
 * Helper method to download files. Pass in the url of resource and the filename. The file will be saved in the docs directory. Completion block is called in the event of
 * success. Check error in case of failure
 */
-(void)downloadFileFromUrl:(NSString*)urlString toFilename:(NSString*)filename withCompletionBlock:(RibotFileDownloaded)completionBlock;


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
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSArray* temp = [defaults arrayForKey:USER_DEFAULTS_UNLOCKED_RIBOTS];;
    
        
        if (!temp)
        {
            //no unlocked ribots yet
            unlockedRibots = [NSMutableArray new];
            
            _isFirstRun = YES;
            
            //save in defaults so we know that this isn't the first run
            [defaults setObject:unlockedRibots forKey:USER_DEFAULTS_UNLOCKED_RIBOTS];
            
            [defaults synchronize];
            
        }
        else
        {
            //load the ones we've unlocked
            unlockedRibots = [temp mutableCopy];
            
            _isFirstRun = NO;
        }
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

-(NSArray *)teamMemberColours
{
    NSMutableArray* colours = [NSMutableArray new];
    
    for (CBRibot* ribot in self.teamMembers)
    {
        UIColor* colour = [self colorWithHexString:ribot.hexColourString];
        
        [colours addObject:colour];
    }
    
    return colours;
}


-(void)downloadFileFromUrl:(NSString*)urlString toDestLocalUrl:(NSURL*)localUrl withCompletionBlock:(RibotFileDownloaded)completionBlock
{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSession* session = [NSURLSession sharedSession];
    
    
    NSURLSessionDownloadTask* task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error)
        {
            //File was downloaded
            NSError* e = nil;
            NSHTTPURLResponse* r = (NSHTTPURLResponse*)response;
            
            if (r.statusCode == 200)
            {
                if ([[NSFileManager defaultManager] moveItemAtURL:location toURL:localUrl error:&e])
                {
                    //Alert calling code that we've downloaded the file
                    completionBlock(localUrl.absoluteString,nil);
                }
                else
                {
                    //Couldn't move file
                    //Pass error back to caller
                    completionBlock(nil,e);
                }
            }
            else
            {
                //Error code returned
                
                //Pass error back to caller
                completionBlock(nil,[NSError errorWithDomain:@"Invalid http status response" code:r.statusCode userInfo:nil]);
            }
        }
        else
        {
            //Error occured.
            //Pass error back to calling code
            completionBlock(nil,error);
        }
    }];
    
    //start the task
    [task resume];
    
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

-(NSURL*)localUrlForRibotarForRibot:(CBRibot*)ribot
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *docsUrl = [NSURL fileURLWithPath:docPath];
    NSString* ribotarFilename = [self filenameForCachedRibotarForRibot:ribot];
    NSURL *fileUrl = [docsUrl URLByAppendingPathComponent:ribotarFilename];
    
    return fileUrl;
}

/**
 * Returns the filename for the specified ribot members ribotar
 */
-(NSString*)filenameForCachedRibotarForRibot:(CBRibot*)ribot
{
    NSString* filename = [[NSString alloc] initWithFormat:@"%@.jpg",[ribot.ribotId stringByReplacingOccurrencesOfString:@" " withString:@""]];

    return filename;
}



#pragma mark -
#pragma mark Download




/**
 * Attempts to downloads the ribotar from the api, if fails: attempts to get it from the website. In production code probably wouldn't do this.
 */
-(void)downloadImageForRibot:(CBRibot*) ribot withLocalUrl:(NSURL*)ribotarLocalUrl withCompletionBlock:(RibotImageDownloaded)completionBlock
{
    NSMutableString* apiImageUrl = [[NSMutableString alloc] initWithFormat:@"%@/team/%@/ribotar", BASE_URL,ribot.ribotId];
    NSString* websiteImageUrl = [[NSString alloc] initWithFormat:@"http://ribot.co.uk/ieias/wp-content/uploads/2014/02/%@@2x.jpg",ribot.ribotId];
    
    
    //Attempt to download ribotar for this member from API
    [self downloadFileFromUrl:apiImageUrl toDestLocalUrl:ribotarLocalUrl withCompletionBlock:^(NSString *localFilename, NSError *error) {
        if (!error)
        {
            NSLog(@"Retrieved ribotar from API: %@",apiImageUrl);
            //pass to calling code
            //Success!
            completionBlock(ribot,localFilename, nil);
        }
        else
        {
            NSLog(@"Failed to retrieve ribotar from API: %@",apiImageUrl);
            
            //Attempt to download ribotar for this member from website
            [self downloadFileFromUrl:websiteImageUrl toDestLocalUrl:ribotarLocalUrl withCompletionBlock:^(NSString *localFilename, NSError *error) {
                if (!error)
                {
                    NSLog(@"Retrieved ribotar from Website: %@",websiteImageUrl);
                    
                    //pass to calling code
                    //Success!
                    completionBlock(ribot,localFilename, nil);
                }
                else
                {
                    NSLog(@"Failed to retrieve ribotar from Website: %@",websiteImageUrl);
                    
                    NSError* e = [[NSError alloc] initWithDomain:@"Image download failed" code:ERROR_CODE_IMAGE_DOWNLOAD_FAILED userInfo:@{@"OriginalError": error}];
                    //Problem downloading the ribotar but we got the ribot!
                    completionBlock(ribot,nil,e);
                    
                }
            }];
            
            
        }
    }];

}



-(void)downloadRibotStudioWithCompletionBlock:(RibotDataDownloaded)completionBlock
{
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@/studio", BASE_URL];
    
    [self downloadDataFromUrl:urlString withCompletionBlock:^(NSDictionary *result, NSError *error)
     {
         
         if (!error)
         {
             //Get studio dic
             
             NSMutableDictionary* resultDict = [result mutableCopy];
             //Make sure we have a key for photos
             
             
             //Photos is optional so make sure we have an empty array if no photos
             if (![resultDict.allKeys containsObject:KEY_STUDIO_PHOTOS])
             {
                 resultDict[KEY_STUDIO_PHOTOS] = [NSMutableArray new];
             }
             
             completionBlock(resultDict,nil);
             
         }
         else
         {
             completionBlock(nil,error);
         }
     }];

}


-(void)downloadRibotTeamMember:(NSString *)ribotId withCompletionBlock:(RibotTeamMemberDownloaded)completionBlock
{
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@/team/%@", BASE_URL, ribotId];
    
    [self downloadDataFromUrl:urlString withCompletionBlock:^(NSDictionary *result, NSError *error)
    {
        //Create Ribot from this dictionary
        
        if (!error)
        {
            CBRibot* ribot = [[CBRibot alloc] initWithRibotJsonDict:result];
            
            //check if this ribot has been unlocked through the game yet
            for (NSString* ribotId in unlockedRibots)
            {
                
                if ([ribot.ribotId isEqualToString:ribotId])
                    ribot.isUnlocked = YES;
            }
            
            
            
            //Check if we have the image
            NSURL* ribotarLocalUrl = [self localUrlForRibotarForRibot:ribot];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:ribotarLocalUrl.path isDirectory:NO])
            {
                [self downloadImageForRibot:ribot withLocalUrl:ribotarLocalUrl withCompletionBlock:^(CBRibot *ribot, NSString *localFilename, NSError *error) {
                   
                    //alert the calling code
                    //if image failed to download we end up with an error here but we still pass the ribot
                    completionBlock(ribot,error);
                }];
            }
            else
            {
                NSLog(@"Ribotar exists for %@",ribot.ribotId);
                completionBlock(ribot,nil);
            }
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


#pragma mark -
#pragma mark Unrelated helpers - Probably shouldnt be here but time is tight

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
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
