//
//  CBGameViewController.m
//  RibotMissionPossible
//
//  Created by chris on 15/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBGameViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "CBGameScene.h"

@interface CBGameViewController ()

@end

@implementation CBGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/**
 * Sorts out the status bar issues
 */
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [CBGameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    


    self.navigationController.navigationBarHidden =YES;
    
    
    __block CBGameViewController* this= self;
    
    //listen to child scene wanting to exit
    [[NSNotificationCenter defaultCenter] addObserverForName:POP_GAME_VIEW_CONTROLLER object:nil queue:nil usingBlock:^(NSNotification *note) {

        this.navigationController.navigationBarHidden = NO;
        [this.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_GAME_VIEW_CONTROLLER object:nil];
    }];
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
