//
//  Utils.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/10/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Utils : NSObject

#pragma mark - UIColor

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithRGBHex:(UInt32)hex andAlpha:(float)alpha;

+ (UIColor *)lighterColorForColor:(UIColor *)c andDelta:(float)delta;
+ (UIColor *)darkerColorForColor:(UIColor *)c andDelta:(float)delta;

#pragma mark - UIImage

+ (UIImage *)tranlucentImageName:(NSString *)sImageName withAlpha:(CGFloat)alpha;
+ (UIImage *)tranlucentImage:(UIImage *)originalImage withAlpha:(CGFloat)alpha;
+ (UIImage *)imageWithColor:(UInt32)hexColor;

#pragma mark - UI

+ (void)configTabbarAppearce;
+ (UITabBarItem *)tabbarItemWithTitle:(NSString *)title unselectedImage:(NSString *)sUnselectedImage selectedImage:(NSString *)sSelectedImage;

+ (UIButton *)createBarButton:(NSString *)imageName position:(UIControlContentHorizontalAlignment)position target:(id)target selector:(SEL)selector;
+ (UIButton *)createBarButtonWithTitle:(NSString *)sTitle textColor:(UInt32)hexColor position:(UIControlContentHorizontalAlignment)position target:(id)target action:(SEL)selector;

#pragma mark - Files

+ (NSString *)documentPath;
+ (NSString *)artworkPath;
+ (NSString *)downloadPath;

#pragma mark - NSString

+ (BOOL)isNotNullString:(NSString *)input;
+ (NSString *)standardLocaleString:(NSString *)string;
+ (BOOL)isAlphanumbericLetter:(NSString *)letter;

#pragma mark - Time

+ (NSString *)timeFormattedForSong:(int)totalSeconds;
+ (NSString *)timeFormattedForList:(int)totalSeconds;

@end
