//
//  CBMyScene.h
//  RibotMissionPossible
//

//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

/**
 * Message is broadcasted when the user wishes to leave the game. The parent view controller listens for it and reponds accordingly
 */
#define POP_GAME_VIEW_CONTROLLER @"popGameVC"

@interface CBGameScene : SKScene<SKPhysicsContactDelegate>

@end
