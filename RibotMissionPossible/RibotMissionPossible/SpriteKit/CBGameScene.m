//
//  CBMyScene.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

/**
 * A little bit of fun to demonstrate the ribot api.
 * Bare with me, first time I've used sprite kit!
 */
#import "CBGameScene.h"
#import "CBRoundedImageHelper.h"


#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)

#define AUDIO_FILENAME_BOMB @"InvaderHit.wav"
#define AUDIO_FILENAME_TICK @"laser.caf"
#define AUDIO_FILENAME_LASER @"laser.caf"

const static uint32_t categoryProjectile = 0x1 << 0;
const static uint32_t categoryInvader = 0x1 << 1;
const static uint32_t categoryPlayer = 0x1 << 2;;
const static uint32_t categoryGameRect = 0x1 << 3;
const static uint32_t categoryBumper = 0x1 << 4;



#define MID_FRAME CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))


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
 * Time between player allowed to fire gun
 */
#define FIRE_DELAY 0.35

/**
 * The maximum amount towards the size of the screen the invaders can move
 */
#define MOVE_MARGIN 20


/**
 * The starting speed of the invaders
 */
#define SPEED_START 2.5f
/**
 * Compound speed increase each time the invaders move down
 */
#define SPEED_INCREMENT 0.5f


#define MOVE_AMOUNT 20
#define PLAYER_MOVE_SPEED 10

/**
 * The key that a pointer to the ribot is stored in the sknode user dict
 */
#define DATA_RIBOT_POINTER @"ribot"

/**
 * The amount of damage inflicted on the player by falling invaders
 */
#define INVADER_FALLING_DAMAGE 0.2

#define INVADER_IN_FORMATION_SHOT_POINTS 10
#define INVADER_FALLING_SHOT_POINTS 50

//#define DEBUG_MODE


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
    NSMutableArray* invaderSprites;
    
    /**
     * Controls which was the invaders move next
     */
    BOOL invadersMovingLeft;
    
    /**
     * COntrols whether or not invaders are moving down a row
     */
    BOOL isMovingDown;
    
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
    
    NSTimeInterval speed;
    
    NSTimeInterval timeSinceLastFire;
    
    /**
     * When this drops to 0 the game is over.
     */
    CGFloat playerHealth;
    /**
     * The label used to display the players health
     */
    SKLabelNode* lbPlayerHealth;

    /**
     * The label used to display the players score
     */
    SKLabelNode* lbPlayerScore;

    /**
     * Set to YES when game is won or lost
     */
    BOOL gameOver;
    
    /**
     * The players score
     */
    NSUInteger score;
}




-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        
    }
    return self;
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
    
    self.physicsBody.categoryBitMask = categoryGameRect;
    self.physicsBody.contactTestBitMask = categoryBumper;
    
    NSArray* ribotMembers;
    
#ifdef DEBUG_MODE
    NSMutableArray* temp = [NSMutableArray new];
    
    for (NSUInteger i = 0;i<INVADER_COUNT;i++)
    {
        CBRibot* ribot = [[CBRibot alloc] initTestRibot];
        [temp addObject: ribot];
        
    }
    
    ribotMembers = temp;
#else
    
    ribotMembers = [self getRibotsToUseForInvaders];
#endif
    
    speed = SPEED_START;
    
    playerHealth = 1;
    score=0;
    
    
    [self createUI];
    //Create the invaders
    [self createInvadersFromRibots:ribotMembers inFrame:self.frame];
    
    
    //Create the "bumper" bounding rect we use to detect when to make the invaders change direction and move down
    CGRect rect = [self rectContainingInvaders:invaderSprites];
    
    rect.origin.x -= MOVE_MARGIN;
    rect.size.width += MOVE_MARGIN *2;
    
    
    bumper = [self createRectNode:rect withCategoryBitMask:categoryBumper andCollisionBitMask:0 andContactTestBitMask:categoryPlayer];
    
    //Hide the bumper rect unless we need for debugging purposes
#ifndef DEBUG_MODE
    
    bumper.path = nil;
    
#endif
    
    
    //Create player
    player = [self createPlayerWithRadius:20 atPosition:CGPointMake(self.view.bounds.size.width / 2.0f, 45)];
    
}



#pragma mark -
#pragma mark Game loop


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    timeSinceLastMove += timeSinceLast;
    
    NSTimeInterval delay = 1.0 / speed;

    
    if (timeSinceLastMove > delay)
    {
      //  playSoundFilename(AUDIO_FILENAME_BOMB, player);
        
    
        timeSinceLastMove = 0;
        CGFloat moveAmount = MOVE_AMOUNT;
        
        CGPoint offset = CGPointZero;
        
        if (invadersMovingLeft)
        {
            offset.x = -moveAmount;
        }
        else
        {
            offset.x = moveAmount;
        }
        
        if (isMovingDown)
        {
            isMovingDown=NO;
            
            offset.y -= moveAmount;
            
            
            //speed up invaders
            speed += SPEED_INCREMENT;
        }
     
        
        [self moveInvaderGroupByOffset:offset];
        
    }
    
    timeSinceLastFire+= timeSinceLast;
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
    
    if (!gameOver)
    {
        [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
        //check players health is ok
        if (playerHealth < 0 || fequal(playerHealth, 0))
        {
            [self gameLost];
        }
    }
    
}


#pragma mark -
#pragma mark UI

-(void)createUI
{
    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Courier"];


    label.fontSize = 15;
    lbPlayerScore = label;
    label.fontColor = [SKColor greenColor];

        [self updatePlayerHealthUI];
    
    label.position = CGPointMake(20 + label.frame.size.width/2, self.size.height - (20 + label.frame.size.height/2));
    [self addChild:label];
    
    
//
    SKLabelNode* healthLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    healthLabel.fontSize = 15;
    lbPlayerHealth = healthLabel;
    
    
    [self updatePlayerHealthUI];
    
    healthLabel.fontColor = [SKColor redColor];
    //6
    healthLabel.position = CGPointMake(self.size.width - healthLabel.frame.size.width/2 - 20, self.size.height - (20 + healthLabel.frame.size.height/2));
    [self addChild:healthLabel];
    
    
    
}

-(void)updatePlayerHealthUI
{
    lbPlayerHealth.text = [NSString stringWithFormat:@"Health: %.1f", playerHealth * 100.0f];
    
}


-(void)updatePlayerScoreUI
{
    lbPlayerScore.text = [NSString stringWithFormat:@"Score: %lul", (unsigned long)score];

    
}


#pragma mark -
#pragma mark Helpers


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
        //add copies of existing invaders
        for(NSUInteger i=0;i<extraNeeded;i++)
        {
            int ribot = arc4random()%members.count;
            
            [invaders addObject:members[ribot]];
        }
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
-(void)createInvadersFromRibots:(NSArray*)ribots inFrame:(CGRect)frame
{
    invaderSprites = [NSMutableArray new];
    
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
    
    CGFloat startX =marginLeft + INVADER_SPACING_HORZ / 2.0f;
    CGFloat startY =marginTop;
    
    
    float nextX= startX;
    float nextY=startY;
    
    
    for(CBRibot* ribot in ribots)
    {
        CGPoint position =CGPointMake(nextX + invaderRadius, nextY + invaderRadius);
        
        SKSpriteNode* sprite = [self createRibotSprite:ribot withRadius:invaderRadius atPosition:position];
        
        
        sprite.userData = [@{DATA_RIBOT_POINTER : ribot
                             }
                           mutableCopy];
        //store pointer for later
        [invaderSprites addObject: sprite];
        
        NSLog(@"Positioning ribot r:%.2f %@", invaderRadius, NSStringFromCGPoint(position));
        
        nextX += incrementX;
        
        if (nextX >= marginRight)
        {
            nextX = startX ;
            nextY -= incrementY;
        }
        
    }
    
    
    
    
}

#pragma mark -
#pragma mark Node movement

-(void)moveInvaderGroupByOffset:(CGPoint)offset
{
    for (SKSpriteNode* node in invaderSprites)
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
-(SKSpriteNode*)createPlayerWithRadius:(CGFloat)radius atPosition:(CGPoint)position
{
    //get the image for the ribot
    UIImage* image = [UIImage imageNamed:@"Spaceship.png"];
    
    SKTexture* texture = [SKTexture textureWithImage:image];
    
    SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.size = CGSizeMake(radius*2, radius*2);
    sprite.position = position;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    sprite.physicsBody.contactTestBitMask = categoryBumper | categoryInvader;
    sprite.physicsBody.categoryBitMask = categoryPlayer;
    sprite.physicsBody.collisionBitMask = 0;
    sprite.physicsBody.affectedByGravity = NO;
    [self addChild:sprite];
    
    
    return sprite;
}


-(SKSpriteNode*)createSpriteWithImage:(UIImage*) image withSize:(CGSize)size atPosition:(CGPoint)position  withCategoryBitMask: (uint32_t)category andCollisionBitMask:(uint32_t)collision andContactTestBitMask:(uint32_t)contact
{
    return [self createSpriteWithImage:image withSize:size atPosition:position withCategoryBitMask:category andCollisionBitMask:collision andContactTestBitMask:contact addToNode: self];
}

-(SKSpriteNode*)createSpriteWithImage:(UIImage*) image withSize:(CGSize)size atPosition:(CGPoint)position  withCategoryBitMask: (uint32_t)category andCollisionBitMask:(uint32_t)collision andContactTestBitMask:(uint32_t)contact addToNode:(SKNode*)node
{
    SKTexture* texture = [SKTexture textureWithImage:image];
    
    SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.size = size;
    sprite.position = position;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
    
    sprite.physicsBody.categoryBitMask = category;
    sprite.physicsBody.contactTestBitMask =contact;
    sprite.physicsBody.collisionBitMask = collision;
     sprite.physicsBody.affectedByGravity = NO;
    [node addChild:sprite];
    

    
    return sprite;
    
}

/**
 * Creates a ribot invader sprite node
 */
-(SKSpriteNode*)createRibotSprite:(CBRibot*)ribot withRadius:(CGFloat)ribotRadius atPosition:(CGPoint)position
{
    //get the image for the ribot
    UIImage* image = nil;
    
#ifdef DEBUG_MODE
    image =[UIImage imageNamed:@"jerome.jpg"];
#else
    
    image = DATA.teamImages[ribot.ribotId];////
#endif
    
    SKTexture* texture = [SKTexture textureWithImage:image];
    
    SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    sprite.size = CGSizeMake(ribotRadius*2, ribotRadius*2);
    sprite.position = position;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ribotRadius];
    sprite.physicsBody.contactTestBitMask = categoryProjectile | categoryPlayer;
    sprite.physicsBody.categoryBitMask = categoryInvader;
    sprite.physicsBody.collisionBitMask = 0;
    sprite.physicsBody.affectedByGravity = NO;
    sprite.physicsBody.mass = 0.2f;
    [self addChild:sprite];
    
    
    return sprite;
}



-(SKEmitterNode*)createParticlesWithName:(NSString*)particleName atPosition:(CGPoint)position
{
    return [self createParticlesWithName:particleName atPosition:position toNode:self];
}
-(SKEmitterNode*)createParticlesWithName:(NSString*)particleName atPosition:(CGPoint)position toNode:(SKNode*)node
{
    
    NSString *burstPath = [[NSBundle mainBundle] pathForResource:particleName ofType:@"sks"];
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
    emitter.position =position;
    
    [node addChild:emitter];
    
    //Remove the emitter after 4 seconds
    [emitter runAction:[SKAction sequence:@[[SKAction waitForDuration:4], [SKAction removeFromParent]]]];
    
    return emitter;
    
}

-(void)addPlayerExplosionAtPosition:(CGPoint)position
{
    
    [self createParticlesWithName:@"ProjectileExplode2" atPosition:position];
    //    [self createParticlesWithName:@"ExplosionSupplement" atPosition:position];
    
    playSoundFilename(AUDIO_FILENAME_BOMB, bumper);
}


-(void)addExplosionAtPosition:(CGPoint)position
{
    [self createParticlesWithName:@"ProjectileExplode3" atPosition:position];
    [self createParticlesWithName:@"ProjectileExplode2" atPosition:position];
    [self createParticlesWithName:@"ExplosionSupplement" atPosition:position];
    
    playSoundFilename(AUDIO_FILENAME_BOMB, bumper);
}

BOOL isFlagSet(uint32_t value, uint32_t bitmask)
{
    return (value & bitmask) == bitmask;
}

/**
 * Returns the SKNode that contacts another.
 *
 * Simplifies the (contact.bodyA.categoryBitMask == categoryGameRect) && (contact.bodyB.categoryBitMask ==  categoryBumper) type stuff
 */
SKNode* contactBetweenNodes(SKPhysicsContact* contact, uint32_t bitmask1,uint32_t bitmask2)
{
    SKNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    uint32_t firstCategoryBitmask = firstNode.physicsBody.categoryBitMask;
    uint32_t secondCategoryBitmask = secondNode.physicsBody.categoryBitMask;
    
    BOOL firstNodeHitSecond = isFlagSet(firstNode.physicsBody.categoryBitMask, firstCategoryBitmask) && isFlagSet(secondNode.physicsBody.categoryBitMask, secondCategoryBitmask);
    BOOL secondNodeHitFirst = isFlagSet(secondNode.physicsBody.categoryBitMask, secondCategoryBitmask) && isFlagSet(firstNode.physicsBody.categoryBitMask, firstCategoryBitmask);
    
    if (firstNodeHitSecond)
    {
        return firstNode;
    }
    else if (secondNodeHitFirst)
    {
        return secondNode;
    }
    
    return nil;
    
}


- (void) didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *firstNode, *secondNode;
    
    firstNode = (SKSpriteNode *)contact.bodyA.node;
    secondNode = (SKSpriteNode *) contact.bodyB.node;
    
    
    //Collisions between the bumper and the arena frame
    if ((contact.bodyA.categoryBitMask == categoryGameRect) && (contact.bodyB.categoryBitMask ==  categoryBumper))
    {
        invadersMovingLeft = !invadersMovingLeft;
        static int i=0;
        
        //Move down when invaders have moved left and right once
        if (++i % 2)
            isMovingDown = YES;
    }
    //Collisions between the bumper and the player
    else if ((contact.bodyA.categoryBitMask == categoryBumper) && (contact.bodyB.categoryBitMask ==  categoryPlayer))
    {
        //Invaders have reached the player.
        //Game is over!
        [self playerKilled];
    }
    //Collisions between the invader and the player
    else if ((contact.bodyA.categoryBitMask == categoryInvader ) && (contact.bodyB.categoryBitMask ==  categoryPlayer))
    {

        
        //Invader has hit the player
        
        [self ribotShot:firstNode];
        
        //Show explosion
        [self addExplosionAtPosition:firstNode.position];
        
        [self playerHit];
    }

    //Collisions between the laser and invader
    else if ((contact.bodyA.categoryBitMask == categoryProjectile) && (contact.bodyB.categoryBitMask ==  categoryInvader))
    {
        //Invader has hit the player
        
        //remove projectile
        [contact.bodyA.node removeFromParent];
        
        [self ribotShot:contact.bodyB.node];
        
        //Show explosion
        [self addExplosionAtPosition:firstNode.position];
        
    }
    
}

-(void)playerHit
{
    playerHealth -= INVADER_FALLING_DAMAGE;
    
    [self addPlayerExplosionAtPosition:player.position];
    
    [self updatePlayerHealthUI];

}

-(void)showPointsIndicatorAtPosition:(CGPoint)position withNumPoints:(NSUInteger)points
{
    
    NSString* msg = [[NSString alloc] initWithFormat:@"%d",INVADER_FALLING_SHOT_POINTS];
    
  //  NSUInteger random = 180 - (arc4random() % 20);
    SKLabelNode* node = [self showMessage:msg atPosition:position withColour:[UIColor greenColor] andEndScale:4 withDuration:0.2 removeAfterDuration:0.4];
//    [node runAction:[SKAction rotateToAngle:random duration:0.2]];
}

/**
 * Occurs when a ribot invader is shot. First time ribot member falls from the sky to try and hit the player, second time ribot is removed
 */
-(void)ribotShot:(SKNode*)ribotNode
{
    

    
    if (ribotNode.physicsBody.affectedByGravity)
    {
        //This must be the second time the invader has been hit so
        //we now can remove it
        [ribotNode removeFromParent];
        
        score += INVADER_FALLING_SHOT_POINTS;
      
        //Show the user how many points they just won
        [self showPointsIndicatorAtPosition:ribotNode.position withNumPoints:INVADER_FALLING_SHOT_POINTS];
    }
    else
    {
        //the first time the invader is hit
        
        
        [self checkIfRibotNeedsUnlocking:ribotNode];
        
        //Invader now drops from the sky
        ribotNode.physicsBody.affectedByGravity = YES;
        
        //Add a little random rotation
        int rotate = arc4random() % 4;
        
        if (rotate % 2 == 0)
            rotate *= -1;
        
        SKAction* action =[SKAction rotateByAngle:rotate duration:1];
        [ribotNode runAction:action];
        
        //Remove it from overall collection
        [invaderSprites removeObject:ribotNode];
        
        score += INVADER_IN_FORMATION_SHOT_POINTS;
        
        //Show the user how many points they just won
        [self showPointsIndicatorAtPosition:ribotNode.position withNumPoints:INVADER_IN_FORMATION_SHOT_POINTS];

        
        
    }
    
    [self updatePlayerScoreUI];
    

    
    if (invaderSprites.count==0)
    {
        //Game has been won!
        [self gameWon];
    }

    
}


/**
 * Displays a message to the user
 */
-(SKLabelNode*)showMessage:(NSString*)message atPosition:(CGPoint)position withColour:(UIColor*)colour andEndScale:(CGFloat)endZoomLevel withDuration:(NSTimeInterval)displayDuration removeAfterDuration:(NSTimeInterval)removeAfterDuration
{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = message;
    myLabel.fontSize = 10;
    myLabel.position = position;
    myLabel.alpha = 0.5;
    myLabel.fontColor = colour;

    [self addChild:myLabel];
    
    
    NSMutableArray* actions = [@[
                                [SKAction fadeInWithDuration:displayDuration]
                                ]mutableCopy];
    
    //if we need to remove, then add the duration and remove actions to the array
    if (removeAfterDuration > 0)
    {
        [actions addObject: [SKAction fadeOutWithDuration:removeAfterDuration]];
        [actions addObject:[SKAction removeFromParent]];
    }
    
    //the action to display the text
    SKAction* displayAndHide = [SKAction sequence:actions];
    
    SKAction* scale = [SKAction scaleTo:endZoomLevel duration:displayDuration/2.0f];
    
    [myLabel runAction:scale];
    // self.view.paused = YES;
    [myLabel runAction:displayAndHide];
    
    return myLabel;
    
}


/**
 * Displays a message to the user
 */
-(SKLabelNode*)showMessage:(NSString*)message
{
    return [self showMessage:message atPosition:MID_FRAME withColour:[UIColor whiteColor] andEndScale:2 withDuration:1 removeAfterDuration:1];
}

-(void)checkIfRibotNeedsUnlocking:(SKNode*)invaderNode
{

    
    NSDictionary* dict =invaderNode.userData;
    CBRibot* ribot =dict[DATA_RIBOT_POINTER];
    
    if (ribot)
    {
        if (!ribot.isUnlocked)
        {
                [DATA unlockRibot:ribot];

            [self showMessage:[[NSString alloc] initWithFormat:@"Ribot unlocked:\n%@!",ribot.ribotId]];
        }
    }
    else
    {
        NSLog(@"Warning, ribot not found in sprite user data");
    }

}

-(void)playerKilled
{
    [self addExplosionAtPosition:player.position];

    
    //play on the bumper because the bumber doesnt leave the scene

    [self gameLost];
}

#pragma mark -
#pragma mark Game State


-(void)gameWon
{
    gameOver =YES;

    [self showFinalMessage:@"You have won!"];
}

-(void)gameLost
{
    gameOver = YES;
    
    [self showFinalMessage:@"You have lost!"];
    
    
}


-(void)removeInvaders
{
    while (invaderSprites.count)
    {
        [[invaderSprites lastObject] removeFromParent];
        [invaderSprites removeLastObject];
    }
}

-(void)showFinalMessage:(NSString*)msg
{
    [self showMessage:msg atPosition:MID_FRAME withColour:[UIColor whiteColor] andEndScale:2 withDuration:1 removeAfterDuration:4];
    
    
    [self removeInvaders];
    
    [player removeFromParent];
    
    [self createParticlesWithName:@"GameWon" atPosition:MID_FRAME];
    
    __block CBGameScene* this= self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [this exitGame];
    });
}


/**
 * Alert parent view controller we want to exit
 */
-(void)exitGame
{
    [[NSNotificationCenter defaultCenter] postNotificationName:POP_GAME_VIEW_CONTROLLER object:self];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    CGPoint pos = location;
    pos.y = player.position.y;
    
    if (gameOver)
    {
        //Do nothing
      //  [self exitGame];
    }
    else
    {
        //Handle taps on scren by moving the player to that position then firing
        CGFloat distance = fabs(player.position.x - location.x);
        

        NSTimeInterval moveTime =  distance / 300;
        SKAction* actionMove = [SKAction moveTo:pos duration:moveTime];

    //    [player.physicsBody applyForce:CGVectorMake(40 * acceleration)]
        [player runAction:actionMove completion:^{
            if (fabs(player.position.x - pos.x) < 0.1)
            {
                [self fireLaser];
            }
        }];
    }
}

void playSoundFilename(NSString* filename,SKNode* node)
{
    SKAction* action = [SKAction playSoundFileNamed:filename waitForCompletion:YES];
    [node runAction:action];
}

-(void)fireLaser
{
    if (timeSinceLastFire > FIRE_DELAY)
    {
        timeSinceLastFire = 0;
        
        SKSpriteNode* node = [self createSpriteWithImage:[UIImage imageNamed:@"Flare2.png"] withSize:CGSizeMake(30, 30) atPosition:player.position withCategoryBitMask:categoryProjectile andCollisionBitMask:0 andContactTestBitMask:categoryInvader];
        
        SKAction* action = [SKAction moveToY:1000 duration:1];
        [node runAction:[SKAction sequence:@[action,[SKAction removeFromParent]]]];

        playSoundFilename(@"laser.caf", node);
    }

}

@end
