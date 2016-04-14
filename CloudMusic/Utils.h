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

#import "TableFooterView.h"
#import "TableHeaderView.h"

#import "PCSEQVisualizer.h"

#define T_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define T_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define DEVICE_SIZE CGSizeMake(MIN(T_WIDTH, T_HEIGHT),MAX(T_WIDTH, T_HEIGHT))
#define DEVICE_SCALE [UIScreen mainScreen].scale

#define NOTIFICATION_RELOAD_DATA @"NOTIFICATION_RELOAD_DATA"
#define NOTIFICATION_LOGIN_DROPBOX @"NOTIFICATION_LOGIN_DROPBOX"

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

+ (void)configNavigationBar;
+ (void)configNavigationController:(UINavigationController *)navController;

+ (UIBarButtonItem *)customBackNavigationWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)createBarButton:(NSString *)imageName position:(UIControlContentHorizontalAlignment)position target:(id)target selector:(SEL)selector;
+ (UIButton *)createBarButtonWithTitle:(NSString *)sTitle font:(UIFont *)font textColor:(UInt32)hexColor position:(UIControlContentHorizontalAlignment)position target:(id)target action:(SEL)selector;
+ (UIButton *)buttonMusicEqualizeqHolderWith:(PCSEQVisualizer *)musicEq target:(id)target action:(SEL)selector;

+ (void)registerNibForTableView:(UITableView *)tblView;

+ (BOOL)isLandscapeDevice;

#pragma mark - Files

+ (NSString *)documentPath;
+ (NSString *)cachePath;
+ (NSString *)artworkPath;
+ (NSString *)dropboxPath;

#pragma mark - NSString

+ (BOOL)isNotNullString:(NSString *)input;
+ (NSString *)standardLocaleString:(NSString *)string;
+ (BOOL)isAlphanumbericLetter:(NSString *)letter;

#pragma mark - Time

+ (NSString *)getDateStringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;
+ (NSString *)timeFormattedForSong:(int)totalSeconds;
+ (NSString *)timeFormattedForList:(int)totalSeconds;
+ (NSString *)getTimestamp;

@end
