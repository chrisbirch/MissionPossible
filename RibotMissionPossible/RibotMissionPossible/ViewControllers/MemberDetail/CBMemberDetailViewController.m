//
//  CBMemberDetailViewController.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBMemberDetailViewController.h"

@interface CBMemberDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbNickname;
@property (weak, nonatomic) IBOutlet UILabel *lbRole;
@property (weak, nonatomic) IBOutlet UITextView *lbDesc;
@property (weak, nonatomic) IBOutlet UILabel *lbTwitter;
@property (weak, nonatomic) IBOutlet UILabel *lbFavSweet;
@property (weak, nonatomic) IBOutlet UILabel *lbFavSeason;

@end

@implementation CBMemberDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Setup header
    UIImage *image = [UIImage imageNamed:@"ribot"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    
    _lbName.text = [[NSString alloc] initWithFormat:@"%@ %@",_ribot.firstName,_ribot.lastName];
    
    _lbNickname.text = _ribot.nickName;
    _lbRole.text =_ribot.role;
    _lbDesc.text = _ribot.ribotDescription;
    _lbTwitter.text = _ribot.twitter;
    _lbFavSweet.text = _ribot.favSweet;
    _lbFavSeason.text = _ribot.favSeason;
    
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
