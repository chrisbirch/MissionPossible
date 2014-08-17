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
#define FIRE_DELAY 0.4

/**
 * The maximum amount towards the size of the screen the invaders can move
 */
#define MOVE_MARGIN 20


#define SPEED_START 2.5f
#define SPEED_INCREMENT


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
    
    SKLabelNode* lbPlayerHealth;
    
    /**
     * Set to YES when game is won or lost
     */
    BOOL gameOver;
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
    player = [self createPlayerWithRadius:30 atPosition:CGPointMake(self.view.bounds.size.width / 2.0f, 20)];
    
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
            [self gameOver];
        }
    }
    
}


#pragma mark -
#pragma mark UI

-(void)createUI
{
//    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
//
//    
//    label.name = kScoreHudName;
//    label.fontSize = 15;
//    //2
//    label.fontColor = [SKColor greenColor];
//    label.text = [NSString stringWithFormat:@"Score: %04u", 0];
//    //3
//    label.position = CGPointMake(20 + scoreLabel.frame.size.width/2, self.size.height - (20 + scoreLabel.frame.size.height/2));
//    [self addChild:label];
//    
    SKLabelNode* healthLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    healthLabel.fontSize = 15;
    lbPlayerHealth = healthLabel;
    
    
    [self updatePlayerHealth];
    
    healthLabel.fontColor = [SKColor redColor];
    //6
    healthLabel.position = CGPointMake(self.size.width - healthLabel.frame.size.width/2 - 20, self.size.height - (20 + healthLabel.frame.size.height/2));
    [self addChild:healthLabel];
    
    
    
}

-(void)updatePlayerHealth
{
    lbPlayerHealth.text = [NSString stringWithFormat:@"Health: %.1f", playerHealth * 100.0f];
    
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
    UIImage* image = [UIImage imageNamed:@"jerome.jpg"];
    
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
    
    [self updatePlayerHealth];

}

-(void)ribotShot:(SKNode*)ribotNode
{
    
    if (ribotNode.physicsBody.affectedByGravity)
    {
        //This must be the second time the invader has been hit so
        //we now can remove it
        [ribotNode removeFromParent];
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
        
        
        //Check to see if player has unlocked this ribot member

        
    }
    

    
    if (invaderSprites.count==0)
    {
        //Game has been won!
        [self gameWon];
    }

    
}
/**
 * Displays a message to the user
 */
-(void)showMessage:(NSString*)message
{
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = message;
    myLabel.fontSize = 10;
    myLabel.position = MID_FRAME;
    //        myLabel.
    myLabel.alpha = 0.5;
    [self addChild:myLabel];
    
    NSTimeInterval time = 0.5;
    
    SKAction* hideMe = [SKAction sequence:@[
                                            [SKAction fadeInWithDuration:time], [SKAction removeFromParent]
                                            ]];
    
    SKAction* scaleMe = [SKAction scaleTo:2 duration:time/2.0f];
    
    [myLabel runAction:scaleMe];
    // self.view.paused = YES;
    [myLabel runAction:hideMe];
    
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
    //[player removeFromParent];

    
    [self addExplosionAtPosition:player.position];

    
    //play on the bumper because the bumber doesnt leave the scene

    [self gameOver];
}

#pragma mark -
#pragma mark Game State


-(void)gameWon
{
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];

    myLabel.text = @"You have won!";
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));

    [self addChild:myLabel];
    
    [player removeFromParent];
    [self createParticlesWithName:@"GameWon" atPosition:MID_FRAME];

    

}

-(void)removeInvaders
{
    while (invaderSprites.count)
    {
        [[invaderSprites lastObject] removeFromParent];
        [invaderSprites removeLastObject];
    }

}
-(void)gameOver
{
    gameOver = YES;
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"You have lost!";
    myLabel.fontSize = 30;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
    
    [self removeInvaders];
    
    [player removeFromParent];
    [self createParticlesWithName:@"GameWon" atPosition:MID_FRAME];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    CGPoint pos = location;
    pos.y = player.position.y;
    
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
        
        SKSpriteNode* node = [self createSpriteWithImage:[UIImage imageNamed:@"jerome.jpg"] withSize:CGSizeMake(10, 10) atPosition:player.position withCategoryBitMask:categoryProjectile andCollisionBitMask:0 andContactTestBitMask:categoryInvader];
        
        SKAction* action = [SKAction moveToY:1000 duration:1];
        [node runAction:[SKAction sequence:@[action,[SKAction removeFromParent]]]];

        [self createParticlesWithName:@"particle01" atPosition:CGPointMake(0, 0) toNode:node];
        
        playSoundFilename(@"laser.caf", node);
    }

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
