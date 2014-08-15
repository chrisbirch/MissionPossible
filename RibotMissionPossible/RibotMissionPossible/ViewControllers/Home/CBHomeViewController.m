//
//  CBHomeViewController.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBHomeViewController.h"
#import "CBRoundedImageHelper.h"


#define SEGUE_SHOW_RIBOTS @"ShowRibots"
#define SEGUE_GET_MORE_RIBOTS @"MoreRibots"


@interface CBHomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbHeading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinny;
@property (weak, nonatomic) IBOutlet UIView *foregroundBox;

@property (weak, nonatomic) IBOutlet UIButton *buttonMyRibots;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetMore;


//@property(nonatomic,strong) NSArray* backgroundPictures;

@end

@implementation CBHomeViewController

-(NSString*)textFromStudioDictionary:(NSDictionary*)studioDict
{
    NSString* text = [[NSString alloc] initWithFormat:@"%@ %@\n%@\n%@\n",studioDict[KEY_STUDIO_NUMBER],studioDict[KEY_STUDIO_STREET],studioDict[KEY_STUDIO_CITY] ,studioDict[KEY_STUDIO_POSTCODE]];
    
    return text;
}

/**
 * Handle this push manually w/o the story board so we can tell the user about the game
 */
- (IBAction)cmMeetTheRibots:(UIButton *)sender
{
    if (DATA.isFirstRun)
    {
        //Tell user about the game
        
        NSString* title = NSLocalizedString(@"ALERT_FIRST_RUN_VIEW_RIBOTS_TITLE", @"title of the alert");
        NSString* msg = NSLocalizedString(@"ALERT_FIRST_RUN_VIEW_RIBOTS_MSG", @"msg of the alert");
        NSString* yes = NSLocalizedString(@"ALERT_FIRST_RUN_VIEW_RIBOTS_YES", @"yes button");
        NSString* no = NSLocalizedString(@"ALERT_FIRST_RUN_VIEW_RIBOTS_NO", @"no button");
                
        [[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil] show];
        
        
        //Show this now, we've alerted the user to whats required
        [self showGetMoreButtonIfHidden];
    }
    else
    {
        [self performSegueWithIdentifier:SEGUE_SHOW_RIBOTS sender:self];
    }
    
}

-(void)showGetMoreButtonIfHidden
{
    if (_buttonGetMore.alpha == 0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _buttonGetMore.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)downloadRibotData
{
    
    __block CBHomeViewController* this = self;
    
    //Download the studio data
    
    [DATA downloadRibotStudioWithCompletionBlock:^(id result, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString* address = [self textFromStudioDictionary:result];
            this.lbAddress.text = address;
            
            [UIView animateWithDuration:0.5 animations:^{
                this.foregroundBox.alpha =1;
            } completion:^(BOOL finished) {
                
            }];
            
        });
    }];

    //and download the team info including images
    
    [DATA downloadRibotTeamWithCompletionBlock:^(NSError *error) {
       if (!error)
       {
           //Round the images
        
           NSMutableDictionary* paths = [NSMutableDictionary new];
           
           for (CBRibot* ribot in DATA.teamMembers)
           {
               NSString* urlString =[DATA localUrlForRibotarForRibot:ribot].path;
               //
               [paths setValue:urlString forKey:ribot.ribotId];
           }
           
           NSArray* colours = DATA.teamMemberColours;
           
           [CBRoundedImageHelper roundedImagesOnDiskWithPaths:paths withOutputSize:RIBOT_IMAGE_CIRCLE_SIZE andStrokeColours:colours andStrokeWidth:RIBOT_IMAGE_CIRCLE_STOKE_WIDTH andCompletionBlock:^(NSDictionary *roundedImages) {
            
               DATA.teamImages = roundedImages;
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   
                   
                   _buttonMyRibots.enabled = YES;
                   
                   this.spinny.hidden = YES;
                   
               });
           
           }];
            
           
       }
    }];
    
    

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Setup header
    UIImage *image = [UIImage imageNamed:@"ribot"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];

    _foregroundBox.alpha = 0;
    
    //This is where we download all the data
    //It will be stored in the CBData singleton instance for use later on
    [self downloadRibotData];

    //Only on the very first run
    if (DATA.isFirstRun)
    {
        //hide the "get more ribots to lure the user into thinking they're not going
        //to have to work for the joy of meeting the ribots!
        _buttonGetMore.alpha = 0;
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark -
#pragma mark Alert view

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //User has been asked if they want to get more ribots or just show the ones they have
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        //User wants more!
        [self performSegueWithIdentifier:SEGUE_GET_MORE_RIBOTS sender:self];
    }
    else
    {
        //User wants to display the existing ones
        [self performSegueWithIdentifier:SEGUE_SHOW_RIBOTS sender:self];
    }
}

@end
