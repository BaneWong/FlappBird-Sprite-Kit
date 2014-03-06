//
//  Score.m
//  FlappyBird
//
//  Created by dbw on 14-3-2.
//  Copyright (c) 2014年 dbw. All rights reserved.
//

#import "Score.h"

@implementation Score

+ (BOOL)registerScore:(NSInteger)score
{
    if(score > [Score bestScore]){
        [Score setBestScore:score];
        return YES;
    }
    return NO;
}

+ (void) setBestScore:(NSInteger) bestScore
{
    [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:kBestScoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) bestScore
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBestScoreKey];
}

@end
