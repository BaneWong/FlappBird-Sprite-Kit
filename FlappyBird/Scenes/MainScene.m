//
//  MainScene.m
//  FlappyBird
//
//  Created by dbw on 14-3-1.
//  Copyright (c) 2014年 dbw. All rights reserved.
//

#import "MainScene.h"
#import "Constants.h"

@interface MainScene() <SKPhysicsContactDelegate>
@property (strong, nonatomic)   SKNode          *moving;
@property (strong, nonatomic)   SKTexture       *groundTexture;
@property (strong, nonatomic)   SKNode          *pairs;
@property (strong, nonatomic)   SKTexture       *pipeTexture1;
@property (strong, nonatomic)   SKTexture       *pipeTexture2;
@property (strong, nonatomic)   SKAction        *movePairAndRemove;
@property (strong, nonatomic)   SKSpriteNode    *bird;
@property (assign, nonatomic)   NSInteger       score;
@property (strong, nonatomic)   SKLabelNode     *scoreLabel;
@property (strong, nonatomic)   SKColor         *skyColor;
@property (assign, nonatomic)   BOOL            canRestart;
@property (assign, nonatomic)   BOOL            start;
@property (assign, nonatomic)   BOOL            over;
//@property (strong, nonatomic)   Score           *score;
@end

@implementation MainScene

- (void)createBird
{
    SKTexture *birdTexture1 = [SKTexture textureWithImageNamed:@"Bird1"];
    birdTexture1.filteringMode = SKTextureFilteringNearest;
    SKTexture *birdTexture2 = [SKTexture textureWithImageNamed:@"Bird2"];
    birdTexture2.filteringMode = SKTextureFilteringNearest;
    
    _bird = [SKSpriteNode spriteNodeWithTexture:birdTexture1];
    
    SKAction *flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[birdTexture1, birdTexture2] timePerFrame:.2]];
    [_bird runAction:flap];
    
    _bird.position = CGPointMake(self.size.width / 4, self.size.height / 2);
    [_bird setScale:2.0];
    
    _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
    _bird.physicsBody.dynamic = NO;
    _bird.physicsBody.categoryBitMask = birdCategory;
//    _bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory;
    _bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    _bird.physicsBody.allowsRotation = NO;   // ???
    
    [self addChild:_bird];
}

- (void)createGround
{
    _moving = [SKNode node];
    
    _groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
    _groundTexture.filteringMode = SKTextureFilteringNearest;
    

    SKAction *moveGround = [SKAction moveByX:-_groundTexture.size.width*2 y:0 duration:0.02*_groundTexture.size.width*2];
    SKAction *resetGround = [SKAction moveByX:_groundTexture.size.width*2 y:0 duration:0];
    SKAction *moveGroundForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGround, resetGround]]];
    
    for (int i = 0; i < 2 + self.size.width / (_groundTexture.size.width * 2); i++) {
        SKSpriteNode *ground = [SKSpriteNode spriteNodeWithTexture:_groundTexture];
        ground.position = CGPointMake(i * _groundTexture.size.width * 2, _groundTexture.size.height);
        [ground setScale:2.0];
        [ground runAction:moveGroundForever];
        [_moving addChild:ground];
    }
}

- (void)createDummy
{
    SKNode *dummy = [SKNode node];
    dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width, _groundTexture.size.height*2)];
    dummy.physicsBody.dynamic = NO;
    dummy.physicsBody.categoryBitMask = worldCategory;
    dummy.physicsBody.contactTestBitMask = birdCategory;
    dummy.position = CGPointMake(self.size.width / 2, _groundTexture.size.height);
    [self addChild:dummy];
}

- (void)createSkyLine
{
    SKTexture *skyLineTexture = [SKTexture textureWithImageNamed:@"SkyLine"];
    skyLineTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction *moveSkyLine = [SKAction moveByX:-skyLineTexture.size.width*2 y:0 duration:0.02*skyLineTexture.size.width*2];
    SKAction *resetSkyLine = [SKAction moveByX:skyLineTexture.size.width*2 y:0 duration:0];
    SKAction *moveSkyLineForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkyLine, resetSkyLine]]];
    for (int i = 0; i < 2 + self.size.width / (skyLineTexture.size.width * 2); i++) {
        SKSpriteNode *skyLine = [SKSpriteNode spriteNodeWithTexture:skyLineTexture];
        skyLine.position = CGPointMake(i * skyLineTexture.size.width * 2, skyLineTexture.size.height + _groundTexture.size.height*2);
        [skyLine setScale:2.0];
        skyLine.zPosition = -1;
        [skyLine runAction:moveSkyLineForever];
        [_moving addChild:skyLine];
    }
}

- (void)createPair
{
    SKSpriteNode *pipe1 = [SKSpriteNode spriteNodeWithTexture:_pipeTexture1];
    SKSpriteNode *pipe2 = [SKSpriteNode spriteNodeWithTexture:_pipeTexture2];
    [pipe1 setScale:2.0];
    [pipe2 setScale:2.0];
    
    CGFloat y = arc4random() % (NSInteger)(self.size.width / 3);
    
    pipe1.position = CGPointMake(0, y);
    pipe2.position = CGPointMake(0, y + _pipeTexture1.size.height*2 + kVerticalPipeGap);
    
    pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
    pipe2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe2.size];
    pipe1.physicsBody.dynamic = NO;
    pipe2.physicsBody.dynamic = NO;
    pipe1.physicsBody.categoryBitMask = pipeCategory;
    pipe2.physicsBody.categoryBitMask = pipeCategory;
    pipe1.physicsBody.contactTestBitMask = birdCategory;
    pipe2.physicsBody.contactTestBitMask = birdCategory;
    
    SKNode *pipePair = [SKNode node];
    pipePair.position = CGPointMake(self.size.width + _pipeTexture1.size.width, 0);
    [pipePair addChild:pipe1];
    [pipePair addChild:pipe2];
    [pipePair runAction:_movePairAndRemove];
    pipePair.zPosition = -1;
    
    SKNode *contactNode = [SKNode node];
    contactNode.position = CGPointMake(pipe1.size.width + _bird.size.width / 2, self.size.height / 2);
    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(pipe1.size.width, self.size.height)];
    contactNode.physicsBody.dynamic = NO;
    contactNode.physicsBody.categoryBitMask = scoreCategory;
    contactNode.physicsBody.contactTestBitMask = birdCategory;
    [pipePair addChild:contactNode];
    
    [_pairs addChild:pipePair];
}

- (void)pairsMoving
{
    _pairs = [SKNode node];
    [_moving addChild:_pairs];

    _pipeTexture1 = [SKTexture textureWithImageNamed:@"Pipe1"];
    _pipeTexture1.filteringMode = SKTextureFilteringNearest;
    _pipeTexture2 = [SKTexture textureWithImageNamed:@"Pipe2"];
    _pipeTexture2.filteringMode = SKTextureFilteringNearest;
    
    CGFloat distanceToMove = self.size.width + _pipeTexture1.size.width * 2;
    SKAction *movePair = [SKAction moveByX:-distanceToMove y:0 duration:0.01*distanceToMove];
    SKAction *removePair = [SKAction removeFromParent];
    _movePairAndRemove = [SKAction sequence:@[movePair, removePair]];
    
    SKAction *createPairThenRemove = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction performSelector:@selector(createPair) onTarget:self],[SKAction waitForDuration:2.0]]]];
    [self runAction:createPairThenRemove];
    
}

- (void)createScoreLabel
{
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
    _scoreLabel.position = CGPointMake(self.size.width / 2, self.size.height / 5 * 4);
    _scoreLabel.text = [NSString stringWithFormat:@"%d", 0];
    [self addChild:_scoreLabel];
}

- (void)startGame
{
    _bird.physicsBody.dynamic = YES;
    [self pairsMoving];
    if ([self.delegate respondsToSelector:@selector(eventStart)]) {
        [self.delegate eventStart];
    }
}

- (void)gameOverWithScore:(NSInteger)score
{
    _moving.speed = 0;
    _bird.physicsBody.collisionBitMask = worldCategory;
    [_bird runAction:[SKAction rotateByAngle:M_PI*_bird.position.y*0.01 duration:_bird.position.y*0.003] completion:^{
        _bird.speed = 0;
        
        if ([self.delegate respondsToSelector:@selector(eventOverWithScore:)]) {
            [self.delegate eventOverWithScore:score];
        }
    }];
    [self removeActionForKey:@"flash"];
    [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
        self.backgroundColor = [SKColor redColor];
    }], [SKAction waitForDuration:0.05], [SKAction runBlock:^{
        self.backgroundColor = _skyColor;
    }], [SKAction waitForDuration:0.05]]] count:4], [SKAction runBlock:^{
        _canRestart = YES;
    }]]] withKey:@"flash"];
    
    
}

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.physicsWorld.gravity = CGVectorMake(0, -5);
        self.physicsWorld.contactDelegate = self;
        _skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
        self.backgroundColor = _skyColor;
        
        self.start = YES;
        self.over = NO;
        
        [self createBird];
        [self createGround];
        [self createDummy];
        [self createSkyLine];
        [self createScoreLabel];
        [self addChild:_moving];

//        [self pairsMoving];

    }
    return self;
}

- (void)resetScene
{
    _bird.position = CGPointMake(self.size.width / 4, self.size.height / 2);
    _bird.physicsBody.velocity = CGVectorMake(0, 0);
    _bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    _bird.speed = 1;
    
    _scoreLabel.text = [NSString stringWithFormat:@"%d", 0];
    _score = 0;
    [_pairs removeAllChildren];
    _canRestart = NO;
    
    _moving.speed = 1;
    
    [self.delegate eventOverWithScore:_score];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.start) {
        self.start = NO;
        [self startGame];
    }
    if (_moving.speed > 0 ) {
        _bird.physicsBody.velocity = CGVectorMake(0, 0);
        [_bird.physicsBody applyImpulse:CGVectorMake(0, 5)];
    } else if (_canRestart){
        [self resetScene];
    }
}

CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    if( _moving.speed > 0 ) {
        _bird.zRotation = clamp( -1, 0.5, _bird.physicsBody.velocity.dy * ( _bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (_moving.speed > 0) {
        if ((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory) {
            _score++;
            _scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
        } else {
            [self gameOverWithScore:_score];
        }
    }
    
}

@end
