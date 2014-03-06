//
//  Score.h
//  FlappyBird
//
//  Created by dbw on 14-3-2.
//  Copyright (c) 2014年 dbw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBestScoreKey @"BestScore"

@interface Score : NSObject

+ (BOOL) registerScore:(NSInteger) score;
+ (void) setBestScore:(NSInteger) bestScore;
+ (NSInteger) bestScore;

@end
