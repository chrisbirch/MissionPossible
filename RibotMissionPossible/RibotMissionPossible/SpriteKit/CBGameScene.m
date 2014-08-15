//
//  CBMyScene.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBGameScene.h"
#import "CBRoundedImageHelper.h"

const static uint32_t projectileCategory = 0x1 << 0;
const static uint32_t invaderCategory = 0x1 << 1;
const static uint32_t playerCategory = 0x1 << 2;;
const static uint32_t gameRect = 0x1 << 3;
const static uint32_t sideBumperCategory = 0x1 << 4;


#define RIBOT_SIZE CGSizeMake(100, 100)


@implementation CBGameScene
{
    // Define instance variables
    SKShapeNode *circle;
//    SKShapeNode *ball;
        SKSpriteNode *ball;
    

    NSTimeInterval lastUpdateTime;
    
    /**
     * Represents the player
     */
    SKSpriteNode* player;
    
    
    /**
     * An array of ribot sprites
     */
    NSMutableArray* ribots;
    
    /**
     * Controls which was the invaders move next
     */
    BOOL invadersMovingLeft;
    
    /**
     * Stores the time that we last moved the invaders
     */
    NSTimeInterval timeSinceLastMove;
    
    /**
     * The amount of offset
     */
    CGFloat invaderGroupOffset;
    
    SKShapeNode* bumper;
    
}



//The spacing between invaders
#define INVADER_SPACING_HORZ 10


//The spacing between invaders
#define INVADER_SPACING_VERT 10

//How far away the invaders start from sides
#define INVADER_MARGIN 80

#define INVADER_MARGIN_Y 120

/**
 * The maximum amount towards the size of the screen the invaders can move
 */
#define MOVE_MARGIN 40


#define SPEED 10

#define DELAY 0.2f /// SPEED

#define MOVE_AMOUNT 50

#define DATA_RIBOT_POINTER @"ribot"
#define DATA_ORIG_X @"originalXPosition"

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    timeSinceLastMove += timeSinceLast;
    
    
    if (timeSinceLastMove > DELAY)
    {
        timeSinceLastMove = 0;
        CGFloat moveAmount = 10;
        
        if (invadersMovingLeft)
        {
            [self moveInvaderGroupByOffset:CGPointMake(-moveAmount, 0)];
        }
        else
        {
            [self moveInvaderGroupByOffset:CGPointMake(moveAmount, 0)];
        }

    }
}

-(void)update:(CFTimeInterval)currentTime
{
    
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTime;
    lastUpdateTime = currentTime;
    
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        lastUpdateTime = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}



-(void)didMoveToView:(SKView *)view
{
    
    SKPhysicsWorld* world = self.physicsWorld;
    
    world.contactDelegate = self;
    
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    // 2 Set physicsBody of scene to borderBody
    self.physicsBody = borderBody;
    // 3 Set the friction of that physicsBody to 0
    self.physicsBody.friction = 0.0f;
    
    self.physicsBody.categoryBitMask = gameRect;
    self.physicsBody.contactTestBitMask = sideBumperCategory;
    
    
   
    
    
    [self createInvaders];

}
/**
 * Lay out a grid of ribot invaders
 */
-(void)createInvaders
{
    ribots = [NSMutableArray new];
    
    float width = self.view.bounds.size.width - (INVADER_MARGIN * 2);
    float numberOfInvadersPerRow=6;
    
    float invaderRadius = (width - INVADER_SPACING_HORZ) / (numberOfInvadersPerRow * 2);//(width / numberOfInvadersPerRow - INVADER_SPACING_HORZ) /2;
    
    CGFloat startX =INVADER_MARGIN;
    CGFloat startY = self.view.bounds.size.height - INVADER_MARGIN_Y;

    
    float nextX= startX;
    float nextY=startY;
    
    CGFloat rightHandSide = startX + INVADER_MARGIN;
    
    NSArray* ribotArray = [DATA.teamMembers copy];

    for(CBRibot* ribot in ribotArray)
    {
        CGPoint position =CGPointMake(nextX + invaderRadius, nextY + invaderRadius);
        
        SKSpriteNode* sprite = [self createRibotSprite:ribot withRadius:invaderRadius atPosition:position];
        
        sprite.userData = [@{
                             DATA_RIBOT_POINTER : ribot,
                             DATA_ORIG_X : [NSNumber numberWithFloat:position.x]
                             }
                           mutableCopy];
        //store pointer for later
        [ribots addObject: sprite];
        
        NSLog(@"Positioning ribot r:%.2f %@", invaderRadius, NSStringFromCGPoint(position));
        
        nextX += (invaderRadius*2) + INVADER_SPACING_HORZ;
        
        if (nextX >= rightHandSide)
        {
            nextX = INVADER_MARGIN ;
            nextY -= (invaderRadius *2) + INVADER_SPACING_VERT;
        }
        
    }
    
    
    
    CGRect bumperRect = CGRectMake(startX-MOVE_MARGIN, startY, rightHandSide + (MOVE_MARGIN*2), nextY - (invaderRadius *2) + INVADER_SPACING_VERT);
    
    CGPoint middle = CGPointMake(CGRectGetMidX(bumperRect), self.view.bounds.size.height - CGRectGetMidY(bumperRect));
//    bumperRect = CGRectMake(-15, -15, 30, 30);
    bumperRect.origin = CGPointMake(-bumperRect.size.width/2.0f, -bumperRect.size.height/2.0f);
    
    
    bumper = [[SKShapeNode alloc] init];
    bumper.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bumperRect.size];
    
    //    bumperRect.origin.x = -bumperRect.size.width/2.0f;
    //  bumperRect.origin.y = -bumperRect.size.height/2.0f;
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:bumperRect];
    bumper.path = path.CGPath;
    
    bumper.position = middle;//CGPointMake(CGRectGetMidX(self.view.bounds),CGRectGetMidY(self.view.bounds));
    
    // 3 Set the friction of that physicsBody to 0
    bumper.physicsBody.friction = 0.0f;
    bumper.physicsBody.categoryBitMask = sideBumperCategory;
    bumper.physicsBody.contactTestBitMask = gameRect;
    
    //dont bounce
     bumper.physicsBody.collisionBitMask = gameRect;
    
    bumper.physicsBody.affectedByGravity = NO;
    [self addChild:bumper];

    
}

-(void)moveInvaderGroupByOffset:(CGPoint)offset
{
    for (SKSpriteNode* node in ribots)
    {
        [self moveSprite:node byOffset:offset];
    }
    
    [self moveSprite:bumper byOffset:offset];
    
}
-(void)moveSprite:(SKSpriteNode*)ribot byOffset:(CGPoint)offset
{
    ribot.position = CGPointMake(ribot.position.x + offset.x, ribot.position.y + offset.y);
}

-(SKSpriteNode*)createRibotSprite:(CBRibot*)ribot withRadius:(CGFloat)ribotRadius atPosition:(CGPoint)position
{
    //get the image for the ribot
    UIImage* image = DATA.teamImages[ribot.ribotId];
                      
    SKTexture* texture = [SKTexture textureWithImage:image];
    
    SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.size = CGSizeMake(ribotRadius*2, ribotRadius*2);
    sprite.position = position;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ribotRadius];
    sprite.physicsBody.contactTestBitMask = invaderCategory;
    sprite.physicsBody.categoryBitMask = invaderCategory;
    sprite.physicsBody.affectedByGravity = NO;
    [self addChild:sprite];
    
    
    

    
    return sprite;
}


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
//        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//        
//        myLabel.text = @"Hello, World!";
//        myLabel.fontSize = 30;
//        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                       CGRectGetMidY(self.frame));
//        
//        [self addChild:myLabel];
        
        
      
        
    }
    return self;
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    static int count=0;
    
//    if (!isFirst)
//        return;
    

    SKSpriteNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    //if ((contact.bodyA.categoryBitMask == nodeBitMask) && (contact.bodyB.categoryBitMask == node1BitMask))
    {
        invadersMovingLeft = !invadersMovingLeft;
        
        CGPoint contactPoint = contact.contactPoint;
//        
//        float contact_y = contactPoint.y;
//        
//        float target_x = secondNode.position.x;
//        float target_y = secondNode.position.y;
//        
//        float margin = secondNode.frame.size.height/2 - 25;
//        
//        if ((contact_y > (target_y - margin)) &&
//            (contact_y < (target_y + margin)))
//        {
            NSString *burstPath =
            [[NSBundle mainBundle]
             pathForResource:@"RibotMiss" ofType:@"sks"];
            
            SKEmitterNode *burstNode =
            [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
        
       // burstNode.
        burstNode.position =contactPoint;
        
        //    [secondNode removeFromParent];
            [self addChild:burstNode];
            
            //self.score++;
//        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    ball.position = location;
    
}
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    /* Called when a touch begins */
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
//}


@end
