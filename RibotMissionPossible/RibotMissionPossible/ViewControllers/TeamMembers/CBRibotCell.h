//
//  CBRibotCell.h
//  RibotMissionPossible
//
//  Created by chris on 15/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REUSE_RIBOT_CELL @"RibotCell"

@interface CBRibotCell : UICollectionViewCell

/**
 * The ribot that this cell represents
 */
@property (nonatomic,strong) CBRibot* ribot;

/**
 * The index path within the collection view
 */
@property (nonatomic,weak) NSIndexPath* indexPath;
@end
