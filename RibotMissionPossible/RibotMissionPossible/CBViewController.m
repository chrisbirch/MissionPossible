//
//  CBViewController.m
//  RibotMissionPossible
//
//  Created by chris on 12/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBViewController.h"
#import "CBRibotWheel.h"


@interface CBViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CBRibotWheel* wheel = [[CBRibotWheel alloc] init];
    
    UIImage* image = [wheel drawWheelImageOfSize: _imageView.bounds.size];
    _imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
