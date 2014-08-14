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


-(void)downloadRibotTeamMember:(NSString *)ribotId withCompletionBlock:(RibotTeamMemberDownloaded)completionBlock
{
    NSString* urlString = [[NSString alloc] initWithFormat:@"%@/team/%@", BASE_URL, ribotId];
    
    [self downloadDataFromUrl:urlString withCompletionBlock:^(NSDictionary *result, NSError *error)
    {
        //Create Ribot from this dictionary
        
        if (!error)
        {
            CBRibot* ribot = [[CBRibot alloc] initWithRibotJsonDict:result];
            
            //Check if we have the image
            NSURL* ribotarLocalUrl = [self localUrlForRibotarForRibot:ribot];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:ribotarLocalUrl.absoluteString isDirectory:NO])
            {
                [self downloadImageForRibot:ribot withLocalUrl:ribotarLocalUrl withCompletionBlock:^(CBRibot *ribot, NSString *localFilename, NSError *error) {
                   
                    //alert the calling code
                    //if image failed to download we end up with an error here but we still pass the ribot
                    completionBlock(ribot,error);
                }];
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



@end
