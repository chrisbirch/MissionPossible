//
//  CBRibotCell.m
//  RibotMissionPossible
//
//  Created by chris on 15/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBRibotCell.h"



@interface CBRibotCell ()
{
    
}
@property (weak, nonatomic) IBOutlet UIImageView *imgRibot;
@property (weak, nonatomic) IBOutlet UILabel *lbRibotName;

@end

@implementation CBRibotCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setRibot:(CBRibot *)ribot
{
    _ribot = ribot;
    
    _lbRibotName.text = ribot.firstName;

}

@end
