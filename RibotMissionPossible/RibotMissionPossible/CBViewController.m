//
//  CBViewController.m
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBViewController.h"
#import "CBRibotWheel.h"
#import <SpriteKit/SpriteKit.h>
#import "CBRoundedImageHelper.h"
#import <SpriteKit/SpriteKit.h>
#import "CBMyScene.h"

@interface CBViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CBViewController


- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ ];
    rotationAnimation.duration = duration;
//    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //Download the ribot data and images
    
    
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [CBMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    
    
    [DATA downloadRibotTeamWithCompletionBlock:^( NSError *error) {
        
        NSArray* teamMembers =DATA.teamMembers;
        NSMutableArray* diskPaths = [NSMutableArray new];
        
        for (CBRibot* ribot in teamMembers)
        {
            //
            [diskPaths addObject: [DATA localUrlForRibotarForRibot: ribot].path];
            
            //
        }
        
        NSArray* teamColours = DATA.teamMemberColours;
        
        [CBRoundedImageHelper roundedImagesOnDiskWithPaths:diskPaths withOutputSize:CGSizeMake(100, 100) andStrokeColours:teamColours andStrokeWidth:5 andCompletionBlock:^(NSArray *roundedImages) {
            
        }];
        
    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
