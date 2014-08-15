//
//  CBHomeViewController.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBHomeViewController.h"

@interface CBHomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbHeading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinny;
@property (weak, nonatomic) IBOutlet UIView *foregroundBox;

@property (weak, nonatomic) IBOutlet UIButton *buttonMyRibots;

@end

@implementation CBHomeViewController

-(NSString*)textFromStudioDictionary:(NSDictionary*)studioDict
{
    NSString* text = [[NSString alloc] initWithFormat:@"%@ %@\n%@\n%@\n",studioDict[KEY_STUDIO_NUMBER],studioDict[KEY_STUDIO_STREET],studioDict[KEY_STUDIO_CITY] ,studioDict[KEY_STUDIO_POSTCODE]];
    
    return text;
}

-(void)downloadRibotData
{
    
    __block CBHomeViewController* this = self;
    
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


    
    [DATA downloadRibotTeamWithCompletionBlock:^(NSError *error) {
       if (!error)
       {
           dispatch_async(dispatch_get_main_queue(), ^{
               _buttonMyRibots.enabled = YES;
               
               this.spinny.hidden = YES;
               
           });
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
    
        [self downloadRibotData];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
