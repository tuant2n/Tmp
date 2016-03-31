//
//  Utils.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/10/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "Utils.h"

@implementation Utils

#pragma mark - UIColor

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    return [self colorWithRGBHex:hex andAlpha:1.0f];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex andAlpha:(float)alpha
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *)lighterColorForColor:(UIColor *)c andDelta:(float)delta
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + delta, 1.0)
                               green:MIN(g + delta, 1.0)
                                blue:MIN(b + delta, 1.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)darkerColorForColor:(UIColor *)c andDelta:(float)delta
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r - delta, 1.0)
                               green:MIN(g - delta, 1.0)
                                blue:MIN(b - delta, 1.0)
                               alpha:a];
    return nil;
}

#pragma mark - UIImage

+ (UIImage *)tranlucentImageName:(NSString *)sImageName withAlpha:(CGFloat)alpha
{
    UIImage *originalImage = [UIImage imageNamed:sImageName];
    return [self tranlucentImage:originalImage withAlpha:alpha];
}

+ (UIImage *)tranlucentImage:(UIImage *)originalImage withAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    [originalImage drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UInt32)hexColor
{
    UIColor *color = [self colorWithRGBHex:hexColor];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - UI

+ (void)configTabbarAppearce
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    UIColor *selectedColor = [self colorWithRGBHex:0x006bd5];
    UIColor *normalColor = [self colorWithRGBHex:0x333333];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:normalColor,
                                                        NSFontAttributeName:font}
                                             forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:selectedColor,
                                                        NSFontAttributeName:font}
                                             forState:UIControlStateSelected];
    
    [[UITabBar appearance] setBackgroundImage:[[self imageWithColor:0xf9f9f9] stretchableImageWithLeftCapWidth:5 topCapHeight:5]];
}

+ (UITabBarItem *)tabbarItemWithTitle:(NSString *)title unselectedImage:(NSString *)sUnselectedImage selectedImage:(NSString *)sSelectedImage
{
    UIImage *selectedImage = [UIImage imageNamed:sSelectedImage];
    UIImage *unselectedImage = [UIImage imageNamed:sUnselectedImage];
    
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    unselectedImage = [unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return [[UITabBarItem alloc] initWithTitle:title image:unselectedImage selectedImage:selectedImage];
}

+ (void)configNavigationBar
{
    UIFont *navigationFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    UIColor *navigationTextColor = [UIColor blackColor];
    
    NSShadow *shadowText = [NSShadow new];
    [shadowText setShadowColor:[UIColor clearColor]];
    [shadowText setShadowBlurRadius:0.0f];
    [shadowText setShadowOffset:CGSizeMake(0.0, 0.0)];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:navigationTextColor,
                                                           NSFontAttributeName:navigationFont,
                                                           NSShadowAttributeName:shadowText}];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    leftView.backgroundColor = [UIColor redColor];
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    searchIcon.image = [UIImage imageNamed:@"textField-search"];
    searchIcon.contentMode = UIViewContentModeCenter;
    [leftView addSubview:searchIcon];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setLeftView:leftView];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setLeftViewMode:UITextFieldViewModeAlways];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setPlaceholder:@"Search"];
}

+ (void)configNavigationController:(UINavigationController *)navController
{
    navController.navigationBar.opaque = NO;
    navController.navigationBar.translucent = NO;
    navController.navigationBar.shadowImage = [UIImage new];
    navController.interactivePopGestureRecognizer.enabled = YES;
}

+ (UIButton *)createBarButton:(NSString *)imageName position:(UIControlContentHorizontalAlignment)position target:(id)target selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setContentHorizontalAlignment:position];
    button.multipleTouchEnabled = NO;
    button.exclusiveTouch = YES;
    
    UIImage *normalImage = [UIImage imageNamed:imageName];
    UIImage *highlightedImage = [self tranlucentImage:[UIImage imageNamed:imageName] withAlpha:0.6];
    
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button setImage:highlightedImage forState:UIControlStateDisabled];
    
    return button;
}

+ (UIButton *)createBarButtonWithTitle:(NSString *)sTitle textColor:(UInt32)hexColor position:(UIControlContentHorizontalAlignment)position target:(id)target action:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, 50.0, 35.0)];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setContentHorizontalAlignment:position];
    button.multipleTouchEnabled = NO;
    button.exclusiveTouch = YES;
    
    [button setTitle:sTitle forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
    
    UIColor *normalColor = [Utils colorWithRGBHex:hexColor];
    UIColor *highlightedColor = [Utils colorWithRGBHex:hexColor andAlpha:0.4];
    
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    [button setTitleColor:highlightedColor forState:UIControlStateDisabled];
    
    return button;
}

+ (UIButton *)buttonMusicEqualizeqHolderWith:(PCSEQVisualizer *)musicEq target:(id)target action:(SEL)selector
{
    UIButton *btnEqHolder = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEqHolder setFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
    btnEqHolder.backgroundColor = [UIColor clearColor];
    [btnEqHolder addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    btnEqHolder.multipleTouchEnabled = NO;
    btnEqHolder.exclusiveTouch = YES;
    
    CGRect frame = musicEq.frame;
    frame.origin.x = (btnEqHolder.frame.size.width - frame.size.width);
    frame.origin.y = (btnEqHolder.frame.size.height - frame.size.height) / 2.0;
    musicEq.frame = frame;
    [btnEqHolder addSubview:musicEq];
    
    return btnEqHolder;
}

+ (void)registerNibForTableView:(UITableView *)tblView
{
    [tblView registerNib:[UINib nibWithNibName:@"SongsCell" bundle:nil] forCellReuseIdentifier:@"SongsCellId"];
    [tblView registerNib:[UINib nibWithNibName:@"AlbumsCell" bundle:nil] forCellReuseIdentifier:@"AlbumsCellId"];
    [tblView registerNib:[UINib nibWithNibName:@"ArtistsCell" bundle:nil] forCellReuseIdentifier:@"ArtistsCellId"];
    [tblView registerNib:[UINib nibWithNibName:@"GenresCell" bundle:nil] forCellReuseIdentifier:@"GenresCellId"];
    [tblView registerNib:[UINib nibWithNibName:@"HeaderTitle" bundle:nil] forCellReuseIdentifier:@"HeaderTitleId"];
    
    [tblView registerNib:[UINib nibWithNibName:@"TableHeaderCell" bundle:nil] forCellReuseIdentifier:@"TableHeaderCellId"];
    
    [tblView registerNib:[UINib nibWithNibName:@"ListSongCell" bundle:nil] forCellReuseIdentifier:@"ListSongCellId"];
    
    tblView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Files

+ (NSString *)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)artworkPath
{
    NSString *artworkPath = [[self documentPath] stringByAppendingPathComponent:@"Artwork"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:artworkPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:artworkPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return artworkPath;
}

+ (NSString *)downloadPath
{
    NSString *downloadPath = [[self documentPath] stringByAppendingPathComponent:@"Downloaded"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return downloadPath;
}

#pragma mark - NSString

+ (BOOL)isNotNullString:(NSString *)input
{
    return ([input isKindOfClass:[NSString class]] && input.length > 0);
}

+ (NSString *)standardLocaleString:(NSString *)string
{
    if (string.length == 0) {
        return nil;
    }
    
    NSString *newString;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSUInteger i = 0; i < string.length; i++)
    {
        NSString *ichar = [string substringWithRange:NSMakeRange(i, 1)];
        NSString *newChar = [self standardLocaleLetter:ichar];
        [arr addObject:newChar];
    }
    newString = [arr componentsJoinedByString:@""];
    
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return newString;
}

+ (NSString *)standardLocaleLetter:(NSString *)letter
{
    letter = [letter lowercaseString];
    
    if (letter.length == 0) {
        return letter;
    }
    
    NSString *regex = @"áàạảãăắằặẳẵâấầậẩẫđéèẹẻẽêếềệểễóòọỏõôốồổộỗơớờợởỡúùụủũưứừựửữíìịỉĩýỳỵỷỹ";
    
    NSRange searchRange = [regex rangeOfString:letter];
    NSUInteger i = searchRange.location;
    
    if (i != NSNotFound) {
        if (i <= 16) {
            letter = @"a";
        }
        else if ((16 < i) && (i <= 17)) {
            letter = @"d";
        }
        else if ((17 < i) && (i <= 28)) {
            letter = @"e";
        }
        else if ((28 < i) && (i <= 45)) {
            letter = @"o";
        }
        else if ((45 < i) && (i <= 56)) {
            letter = @"u";
        }
        else if ((56 < i) && (i <= 61)) {
            letter = @"i";
        }
        else if ((61 < i) && (i <= 66)) {
            letter = @"y";
        }
    }
    
    return letter;
}

+ (BOOL)isAlphanumbericLetter:(NSString *)letter
{
    if (letter.length == 0) {
        return NO;
    }
    
    NSString *regex = @"[A-Z]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL valid = [predicate evaluateWithObject:letter];
    return valid;
}

#pragma mark - Time

+ (NSString *)timeFormattedForSong:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
    }
    else {
        return [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    }
}

+ (NSString *)timeFormattedForList:(int)totalSeconds
{
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%d hour %d min",hours,minutes];
    }
    else {
        return [NSString stringWithFormat:@"%d min",minutes];
    }
}

@end
