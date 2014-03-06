//
//  MainScene.h
//  FlappyBird
//
//  Created by dbw on 14-3-1.
//  Copyright (c) 2014年 dbw. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol MainSceneDelegate <NSObject>
- (void) eventStart;
- (void) eventOverWithScore:(NSInteger)score;
//- (void) eventWasted;
@end

@interface MainScene : SKScene
@property (unsafe_unretained,nonatomic) id<MainSceneDelegate> delegate;
@end
