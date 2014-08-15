//
//  CBMemberDetailViewController.h
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBRibot.h"
@interface CBMemberDetailViewController : UIViewController

/**
 * The staff member we are showing in detail
 */
@property (nonatomic,weak) CBRibot* ribot;

@end
