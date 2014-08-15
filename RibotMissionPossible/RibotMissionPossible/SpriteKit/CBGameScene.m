//
//  CBMyScene.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBGameScene.h"
#import "CBRoundedImageHelper.h"

const static uint32_t categoryProjectile = 0x1 << 0;
const static uint32_t categoryInvader = 0x1 << 1;
const static uint32_t categoryPlayer = 0x1 << 2;;
const static uint32_t categoryGameRect = 0x1 << 3;
const static uint32_t categoryBumper = 0x1 << 4;


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
    
    /**
     * Used to detect when the invaders have reached oneside of the arena
     */
    SKShapeNode* bumper;
    
}

/**
 * The number of invaders per row
 */
#define INVADERS_PER_ROW 5

#define INVADERS_ROWS 4

#define INVADER_COUNT INVADERS_PER_ROW * INVADERS_ROWS


//The spacing between invaders
#define INVADER_SPACING_HORZ 10


//The spacing between invaders
#define INVADER_SPACING_VERT 10

//How far away the invaders start from sides
#define INVADER_MARGIN 40

#define INVADER_MARGIN_Y 120

/**
 * The maximum amount towards the size of the screen the invaders can move
 */
#define MOVE_MARGIN 20


#define SPEED 10

#define DELAY 0.2f /// SPEED

#define MOVE_AMOUNT 50

#define DATA_RIBOT_POINTER @"ribot"


#pragma mark -
#pragma mark Game loop


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


#pragma mark -
#pragma mark Lifecycle


-(void)didMoveToView:(SKView *)view
{
    
    SKPhysicsWorld* world = self.physicsWorld;
    
    world.contactDelegate = self;
    
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    // 2 Set physicsBody of scene to borderBody
    self.physicsBody = borderBody;
    // 3 Set the friction of that physicsBody to 0
    self.physicsBody.friction = 0.0f;
    
    self.physicsBody.categoryBitMask = categoryGameRect;
    self.physicsBody.contactTestBitMask = categoryBumper;
    
    [self createInvadersInFrame:self.frame];
    
}

/**
 * A CGRect that contains all nodes contained within the invaders array
 */
-(CGRect)rectContainingInvaders:(NSArray*)invaders
{
    CGRect container = CGRectZero;;
    
    for (SKSpriteNode* node in invaders)
    {
        CGRect frame = node.frame;
        
        if (CGRectIsEmpty(container))
            container = frame;
        else
            container = CGRectUnion(container, frame);
    }
    
    
    return container;
}

/**
 * Returns an array of CBRibot instances ready to be turned into ribot invaders
 */
-(NSArray*)getRibotsToUseForInvaders
{
    NSArray* members = [DATA.teamMembers copy];
    
    NSMutableArray* invaders = [members mutableCopy];
    
    NSInteger extraNeeded =  INVADER_COUNT - members.count;
    
    if (extraNeeded > 0)
    {
        int ribot = arc4random()%members.count;
        
        [invaders addObject:members[ribot]];
    }
    else
    {
        //TODO: In future version check that we dont have too many!
    }
    
    return invaders;
}


/**
 * Lay out a grid of ribot invaders
 */
-(void)createInvadersInFrame:(CGRect)frame
{
    ribots = [NSMutableArray new];
    
    CGRect layoutInRect = frame;
    
    
    //OpenGL origin is at the bottom left, we need to draw the invaders starting from the top
    //and move down by decremented the Y value
    layoutInRect.origin.y = CGRectGetMaxY(layoutInRect);
    
    //Move away from sides of screen
    layoutInRect.size.width -= (INVADER_MARGIN *2);
    layoutInRect.origin.x = INVADER_MARGIN;
    
    float width = layoutInRect.size.width;
    
    //Calculate the radius of an individual ribot invader
    float invaderRadius = ((width  / INVADERS_PER_ROW)  - INVADER_SPACING_HORZ)/2.0f;
    
    //Position the invaders at the top but far enough away so we dont go off screen
    layoutInRect.origin.y -= invaderRadius*2;
    
    CGFloat marginLeft = layoutInRect.origin.x;
    CGFloat marginRight = CGRectGetMaxX(layoutInRect);
    CGFloat marginTop = layoutInRect.origin.y;
    
    //The amount of units we move when we want to layout the next ribot
    CGFloat incrementX = (invaderRadius *2) + INVADER_SPACING_HORZ;
    CGFloat incrementY = (invaderRadius *2) + INVADER_SPACING_VERT;
    
    CGFloat startX =marginLeft;
    CGFloat startY =marginTop;
    
    
    float nextX= startX;
    float nextY=startY;
    
    
    NSArray* ribotArray = [DATA.teamMembers copy];
    ribotArray = @[@(1),@(1),@(1),@(1),@(1),@(1),@(1),@(1),@(1),@(1)];
    
    for(CBRibot* ribot in ribotArray)
    {
        CGPoint position =CGPointMake(nextX , nextY);
        
        SKSpriteNode* sprite = [self createRibotSprite:ribot withRadius:invaderRadius atPosition:position];
        
        
        sprite.userData = [@{DATA_RIBOT_POINTER : ribot
                             }
                           mutableCopy];
        //store pointer for later
        [ribots addObject: sprite];
        
        NSLog(@"Positioning ribot r:%.2f %@", invaderRadius, NSStringFromCGPoint(position));
        
        nextX += incrementX;
        
        if (nextX >= marginRight)
        {
            nextX = startX ;
            nextY -= incrementY;
        }
        
    }
    
    CGRect rect = [self rectContainingInvaders:ribots];
    
    rect.origin.x -= MOVE_MARGIN;
    rect.size.width += MOVE_MARGIN *2;
    
    
    bumper = [self createRectNode:rect withCategoryBitMask:categoryBumper andCollisionBitMask:categoryGameRect andContactTestBitMask:categoryGameRect];
    
    
    
    
}

#pragma mark -
#pragma mark Node movement

-(void)moveInvaderGroupByOffset:(CGPoint)offset
{
    for (SKSpriteNode* node in ribots)
    {
        [self moveNode:node byOffset:offset];
    }
    
    [self moveNode:bumper byOffset:offset];
    
}
-(void)moveNode:(SKNode*)ribot byOffset:(CGPoint)offset
{
    ribot.position = CGPointMake(ribot.position.x + offset.x, ribot.position.y + offset.y);
}

#pragma mark -
#pragma mark Create Nodes


/**
 * Helpers to create a rectanglular node at the specifed position
 */
-(SKShapeNode*)createRectNode:(CGRect)rect withCategoryBitMask: (uint32_t)category andCollisionBitMask:(uint32_t)collision andContactTestBitMask:(uint32_t)contact
{
    
    //Work out the middle of the rect and adjust the rects origin
    CGPoint middle = CGPointMake(CGRectGetMidX(rect),   CGRectGetMidY(rect));
    rect.origin = CGPointMake(-rect.size.width/2.0f, -rect.size.height/2.0f);
    
    //Create the node and its graphics
    SKShapeNode* node = [[SKShapeNode alloc] init];
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    node.path = path.CGPath;
    
    node.position = middle;
    
    //Physics body
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rect.size];
    node.physicsBody.friction = 0.0f;
    node.physicsBody.categoryBitMask = category;
    node.physicsBody.contactTestBitMask =contact;
    node.physicsBody.collisionBitMask = collision;
    
    node.physicsBody.affectedByGravity = NO;
    
    [self addChild:node];
    
    return node;
}


/**
 * Creates a ribot invader sprite node
 */
-(SKSpriteNode*)createRibotSprite:(CBRibot*)ribot withRadius:(CGFloat)ribotRadius atPosition:(CGPoint)position
{
    //get the image for the ribot
    UIImage* image = [UIImage imageNamed:@"jerome.jpg"];// DATA.teamImages[ribot.ribotId];
    
    SKTexture* texture = [SKTexture textureWithImage:image];
    
    SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.size = CGSizeMake(ribotRadius*2, ribotRadius*2);
    sprite.position = position;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ribotRadius];
    sprite.physicsBody.contactTestBitMask = categoryInvader;
    sprite.physicsBody.categoryBitMask = categoryInvader;
    sprite.physicsBody.collisionBitMask = 0;
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
    
    //if ((contact.bodyA.categoryBitMask == categoryBumper) && (contact.bodyB.categoryBitMask == categoryGameRect))
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
