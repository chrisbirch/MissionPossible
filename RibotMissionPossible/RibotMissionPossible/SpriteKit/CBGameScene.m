//
//  CBMyScene.m
//  RibotMissionPossible
//
//  Created by chris on 14/08/2014.
//  Copyright (c) 2014 Chris Birch. All rights reserved.
//

#import "CBGameScene.h"
#import "CBRoundedImageHelper.h"

const static int nodeBitMask = 0x1 << 0;
const static int node1BitMask = 0x1 << 1;;

@implementation CBGameScene
{
    // Define instance variables
    SKShapeNode *circle;
//    SKShapeNode *ball;
        SKSpriteNode *ball;
}

-(void)didMoveToView:(SKView *)view
{
    
    SKPhysicsWorld* world = self.physicsWorld;
    
    world.contactDelegate = self;
    
    // Insert this code in the init method of your scene
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, 0, 0, 100, 0, M_PI * 2, YES);
    
    circle = [[SKShapeNode alloc] init];
    circle.path = circlePath;
    circle.position = CGPointMake(150, 150);
    circle.lineWidth = 1.0;
    
    
    circle.fillColor = [SKColor blueColor];
    circle.strokeColor = [SKColor whiteColor];

    circle.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:circlePath];

    circle.physicsBody.contactTestBitMask = node1BitMask;
    circle.physicsBody.categoryBitMask = nodeBitMask;
//    circle.physicsBody.collisionBitMask = nodeBitMask;
    
    
    [self addChild:circle];
    
    CGSize size = CGSizeMake(100, 100);
    
    UIImage* image = [UIImage imageNamed:@"jerome.jpg"];
    image = [CBRoundedImageHelper roundedImageFromImage:image withOutputSize:size andStrokeColour:[UIColor redColor] andStrokeWidth:4];
    SKTexture* texture = [SKTexture textureWithImage:image];
    
    
    ball = [SKSpriteNode spriteNodeWithTexture:texture];
    ball.size = size;
    ball.position = CGPointMake(100, 100);

    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:50];
    ball.physicsBody.contactTestBitMask = nodeBitMask;
    ball.physicsBody.categoryBitMask = node1BitMask;
  //  ball.physicsBody.collisionBitMask = nodeBitMask;
    
    
    //CGMutablePathRef ballPath = CGPathCreateMutable();
    //CGPathAddArc(ballPath, NULL, 0, 0, 15, 0, M_PI * 2, YES);
    //
    //        ball = [[SKSpriteNode alloc] init];
    //        ball.path = ballPath;
    //        ball.position = CGPointMake(200, 200);
    //        ball.lineWidth = 1.0;
    //        ball.fillColor = [SKColor redColor];
    //        ball.strokeColor = [SKColor greenColor];
    //        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15];
    
    [self addChild:ball];

    
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
    
    count++;
    
    if (count % 10)
    {
    if ((contact.bodyA.categoryBitMask == nodeBitMask) && (contact.bodyB.categoryBitMask == node1BitMask))
    {
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
