//
//  GameScene.m
//  HelloSpriekit
//
//  Created by 武淅 段 on 16/3/31.
//  Copyright (c) 2016年 武淅 段. All rights reserved.
//

#import "GameScene.h"

@interface GameScene() <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic, assign) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic, assign) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic, assign) NSInteger monstersDestoryed;

@end

static const uint32_t shootCategory = 0x1 << 0;
static const uint32_t monsterCategory = 0x1 << 1;


static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if(self){
        NSLog(@"size : %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithWhite:1.0 alpha:1.0];
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        self.player.size = CGSizeMake(50, 50);
        self.player.position = CGPointMake(size.width/2.0, self.player.size.height/2.0);

        [self addChild:self.player];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}


- (void) addMonster
{
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    monster.size = CGSizeMake(50, 50);
    int minY = monster.size.height/2.0;
    int maxY = self.frame.size.height-monster.size.height/2.0;
    int rangeY = maxY-minY;
    int acturalY = (arc4random()%rangeY)+minY;
    monster.position = CGPointMake(self.frame.size.width+monster.size.width/2.0, acturalY);
    [self addChild:monster];
    
    int minD = 2.0;
    int maxD = 4.0;
    int rangeD = maxD-minD;
    int acturalD = (arc4random()%rangeD)+minD;
    SKAction *move = [SKAction moveTo:CGPointMake(-monster.size.width/2.0, acturalY) duration:acturalD];
    SKAction *done = [SKAction removeFromParent];
    SKAction *gameOverAction = [SKAction runBlock:^{
       
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc]initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition:reveal];
    }];
    
    [monster runAction:[SKAction sequence:@[move,gameOverAction,done]]];
    
    /*
     将categoryBitMask设置为之前定义好的monsterCategory。
     
     contactTestBitMask表示与什么类型对象碰撞时，应该通知contact代理。在这里选择炮弹类型。
     
     collisionBitMask表示物理引擎需要处理的碰撞事件。在此处我们不希望炮弹和怪物被相互弹开——所以再次将其设置为0。
     */
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = shootCategory;
//    monster.physicsBody.collisionBitMask = 0;
}


- (void) updateWithTimeSinceLastUpdate : (NSTimeInterval)timeSinceLast
{
    self.lastSpawnTimeInterval += timeSinceLast;
    if(self.lastSpawnTimeInterval>1){
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

//Sprite Kit在显示每帧时都会调用上面的update:方法。
- (void) update : (NSTimeInterval) currentTime
{
    NSTimeInterval timeSinceLast = currentTime-self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if(timeSinceLast > 1){
        timeSinceLast = 1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKSpriteNode *shoot = [SKSpriteNode spriteNodeWithImageNamed:@"shoot"];
    shoot.size = CGSizeMake(20, 20);
    shoot.position = self.player.position;
    
    CGPoint offset = rwSub(location, shoot.position);
    if(offset.y <= 0){  //至允许向上发射
        return;
    }
    
    [self addChild:shoot];
    
    CGPoint direction = rwNormalize(offset);
    CGPoint shootAmount = rwMult(direction, 1000);
    
    CGPoint realDes = rwAdd(shootAmount, shoot.position);
    
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width/velocity;
    SKAction *move = [SKAction moveTo:realDes duration:realMoveDuration];
    SKAction *done = [SKAction removeFromParent];
    [shoot runAction:[SKAction sequence:@[move, done]]];
    
    shoot.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shoot.size.width/2.0];
    shoot.physicsBody.dynamic = YES;
    shoot.physicsBody.categoryBitMask = shootCategory;
    shoot.physicsBody.contactTestBitMask = monsterCategory;
//    shoot.physicsBody.collisionBitMask = 0;
    shoot.physicsBody.usesPreciseCollisionDetection = YES;  //usesPreciseCollisionDetection属性设置为YES。这对于快速移动的物体非常重要(例如炮弹)，如果不这样设置的话，有可能快速移动的两个物体会直接相互穿过去，而不会检测到碰撞的发生。
    
//    [self runAction:[SKAction playSoundFileNamed:@"" waitForCompletion:NO]];  //播放音效
}

- (void) shoot : (SKSpriteNode *)shoot didCollideWithMonster : (SKSpriteNode *)monster
{
    

    NSLog(@"\n\nhit\n\n");
    [monster removeFromParent];
    [shoot removeFromParent];
    _monstersDestoryed++;
    if(_monstersDestoryed > 30){
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc]initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition:reveal];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if(contact.bodyA.categoryBitMask<contact.bodyB.categoryBitMask){
        firstBody =  contact.bodyA;
        secondBody = contact.bodyB;
    }
    else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if((firstBody.categoryBitMask & shootCategory) && (secondBody.categoryBitMask & monsterCategory)){
        [self shoot:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
}
@end
