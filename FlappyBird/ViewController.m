//
//  ViewController.m
//  FlappyBird
//
//  Created by dbw on 14-3-1.
//  Copyright (c) 2014年 dbw. All rights reserved.
//

#import "ViewController.h"
#import "MainScene.h"
#import "Score.h"

@interface ViewController() <MainSceneDelegate>
@property (weak, nonatomic) IBOutlet UIView *getReadyView;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UIImageView *medalImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentScore;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    MainScene *mainScene = [MainScene sceneWithSize:skView.bounds.size];
    mainScene.scaleMode = SKSceneScaleModeAspectFill;
    mainScene.delegate = self;
    
    [skView presentScene:mainScene];
}

- (void)eventStart
{
    [UIView animateWithDuration:0.8 animations:^{
        self.getReadyView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.getReadyView removeFromSuperview];
    }];
}

- (void)eventOverWithScore:(NSInteger)score
{
    self.view.userInteractionEnabled = NO;
    if (self.gameOverView.alpha) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.userInteractionEnabled = YES;
            self.gameOverView.alpha = 0;
        }];
    } else {
        self.currentScore.text = [NSString stringWithFormat:@"%d", score];
        UIImage *medalImage = [Score registerScore:score] ? [UIImage imageNamed:@"medal_gold"] : [UIImage imageNamed:@"medal_silver"];
        [self.medalImageView setImage:medalImage];
        
        self.bestScoreLabel.text = [NSString stringWithFormat:@"%d", [Score bestScore]];
        [UIView animateWithDuration:0.8 animations:^{
            self.gameOverView.alpha = 1;
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.getReadyView.alpha) {
        self.getReadyView.alpha = 0;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
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

@end
