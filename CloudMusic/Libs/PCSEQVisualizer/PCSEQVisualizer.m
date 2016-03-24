//
//  HNHHEQVisualizer.m
//  HNHH
//
//  Created by Dobango on 9/17/13.
//  Copyright (c) 2013 RC. All rights reserved.
//

#import "PCSEQVisualizer.h"

#import "Utils.h"
#import "GlobalParameter.h"

@implementation PCSEQVisualizer
{
    NSTimer *timer;
    float maxHeight;
    int numberOfBars;
}

- (id)initWithNumberOfBars:(int)number barWidth:(float)barWidth height:(float)height color:(UInt32)hexColor
{
    self = [super init];
    
    if (self)
    {
        maxHeight = height;
        numberOfBars = number;
        
        self.frame = CGRectMake(0, 0, barWidth*(2*numberOfBars - 1), maxHeight);
        self.backgroundColor = [UIColor clearColor];
        self.hidden = NO;
        self.userInteractionEnabled = NO;

        self.barArray = [[NSMutableArray alloc]initWithCapacity:numberOfBars];
        for (int i = 0; i < numberOfBars; i++)
        {
            float barHeigth = (float)(numberOfBars - i)/numberOfBars * (float)maxHeight;;
            float barX = (2 * i)*barWidth;
            
            UIImageView *bar = [[UIImageView alloc] initWithFrame:CGRectMake(barX, 0, barWidth, barHeigth)];
            bar.image = [Utils imageWithColor:hexColor];
            
            [self addSubview:bar];
            [self.barArray addObject:bar];
        }
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2*2);
        self.transform = transform;
    }
    
    return self;
}

#pragma mark - Action

- (void)startEq
{
    [UIView animateWithDuration:.3 animations:^{
        [self randomBars];
    } completion:^(BOOL finished) {
        [self startTimer];
    }];
}

- (void)stopEq:(BOOL)animated
{
    [self stopTimer];
    [self resetBars:animated];
}

#pragma mark - Timer

- (void)startTimer
{
    [self stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(ticker) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (timer.isValid) {
        [timer invalidate];
    }
    timer = nil;
}

- (void)ticker
{
    [UIView animateWithDuration:.3 animations:^{
        [self randomBars];
    }];
}

#pragma mark - Bars

- (void)resetBars:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:.3 animations:^{
            [self resetBars];
        }];
    }
    else {
        [self resetBars];
    }
}

- (void)resetBars
{
    for (int i = 0; i < self.barArray.count; i++)
    {
        UIImageView *bar = self.barArray[i];
        CGRect rect = bar.frame;
        rect.size.height = (float)(numberOfBars - i)/numberOfBars * (float)maxHeight;
        bar.frame = rect;
    }
}

- (void)randomBars
{
    for (int i = 0; i < self.barArray.count; i++)
    {
        UIImageView *bar = self.barArray[i];
        CGRect rect = bar.frame;
        rect.size.height = ceilf(arc4random() % (int)maxHeight);
        bar.frame = rect;
    }
}

#pragma mark - Utils

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
