//
//  GameOverScene.m
//  HelloSpriekit
//
//  Created by 武淅 段 on 16/3/31.
//  Copyright © 2016年 武淅 段. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene

- (id)initWithSize:(CGSize)size won:(BOOL)won
{
    if(self = [super initWithSize:size]){
        
        self.backgroundColor = [SKColor colorWithWhite:1.0 alpha:1.0];
        NSString *message = won? @"You Won!" : @"You Lose!";
        SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        labelNode.text = message;
        labelNode.fontSize = 40;
        labelNode.position = CGPointMake(size.width/2.0, size.height/2);
        labelNode.fontColor = [SKColor blackColor];
        [self addChild:labelNode];
        
        [self runAction:[SKAction sequence:@[
                                             [SKAction waitForDuration:3.0],
                                             [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene *myScene = [[GameScene alloc]initWithSize:self.size];
            [self.view presentScene:myScene transition:reveal];
        }]
                                             ]
                         ]
         ];
    }
    
    return self;
}

@end
