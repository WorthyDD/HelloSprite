//
//  GameViewController.m
//  HelloSpriekit
//
//  Created by 武淅 段 on 16/3/31.
//  Copyright (c) 2016年 武淅 段. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface GameViewController()

@property (nonatomic) AVAudioPlayer *musicPlayer;
@end


@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene sceneWithSize:[UIScreen mainScreen].bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSError *err;
    NSURL *bgMusicURL = [[NSBundle mainBundle] URLForResource:@"bg" withExtension:@"mp3"];
    if(!self.musicPlayer){
        self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:bgMusicURL error:&err];
        if(err){
            NSLog(@"\nerror:%@",err);
        }
    }
    self.musicPlayer.numberOfLoops = -1;
    [self.musicPlayer prepareToPlay];
    [self.musicPlayer play];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
