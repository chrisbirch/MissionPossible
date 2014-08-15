//
//  CBTeamMembersViewController.m
//  RibotMissionPossible
//
//  Created by chris on 15/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBTeamMembersViewController.h"
#import "CBRibotCell.h"
#import "CBMemberDetailViewController.h"


#define SEGUE_RIBOT_DETAIL @"RibotDetail"

@interface CBTeamMembersViewController ()
{
    NSArray* members;

}
@end

@implementation CBTeamMembersViewController

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
    
    members = DATA.teamMembers;
    
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
    if ([segue.identifier isEqualToString:SEGUE_RIBOT_DETAIL])
    {
        CBMemberDetailViewController* vc = segue.destinationViewController;
        
        vc.ribot = ((CBRibotCell*) sender).ribot;
        
        
    }
}

#pragma mark -
#pragma mark Collection view

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CBRibot* ribot = members[indexPath.row];
    
    CBRibotCell* cell = (CBRibotCell*)[collectionView dequeueReusableCellWithReuseIdentifier:REUSE_RIBOT_CELL forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.ribot = ribot;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return members.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for (CBRibotCell* cell in collectionView.visibleCells)
    {
        if (cell.indexPath == indexPath)
        {
            [self performSegueWithIdentifier:SEGUE_RIBOT_DETAIL sender:cell];
        }
    }
    
    
    

}
@end
