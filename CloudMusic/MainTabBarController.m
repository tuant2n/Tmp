//
//  MainTabBarController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "MainTabBarController.h"

#import "MoreTableViewDelegate.h"

#import "Utils.h"
#import "DataManagement.h"
#import "GlobalParameter.h"

#import "FilesViewController.h"
#import "SongsViewController.h"
#import "AlbumsViewController.h"
#import "PlaylistsViewController.h"
#import "ArtistsViewController.h"
#import "GenresViewController.h"
#import "SettingsViewController.h"

#import "PlayerViewController.h"

#import "IQKeyboardManager.h"
#import "MBProgressHUD.h"

typedef enum {
    kTabTypeFiles,
    kTabTypeSongs,
    kTabTypeAlbums,
    kTabTypePlaylists,
    kTabTypeArtists,
    kTabTypeGenres,
    kTabTypeSettings
} kTabType;

@interface MainTabBarController () <UITabBarControllerDelegate,UINavigationControllerDelegate>
{
    
}

@property (nonatomic, strong) UINavigationController *navFilesVC, *navSongsVC, *navAlbumsVC, *navPlaylistsVC, *navArtistsVC, *navGenresVC, *navSettingsVC;
@property (nonatomic, strong) MoreTableViewDelegate *tabBarMoreViewDelegate;

@property (nonatomic, strong) MBProgressHUD *syncDataProgress;

@end

@implementation MainTabBarController

- (MBProgressHUD *)syncDataProgress
{
    if (!_syncDataProgress) {
        _syncDataProgress = [[MBProgressHUD alloc] initWithView:self.view];
        _syncDataProgress.mode = MBProgressHUDModeIndeterminate;
        _syncDataProgress.labelText = @"Sync Data...";
    }
    return _syncDataProgress;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self createTabViews];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPlayer) name:NOTIFICATION_OPEN_PLAYER object:nil];
}

- (void)initData
{
#if !(TARGET_OS_SIMULATOR)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_iPodLibraryDidChange:) name: MPMediaLibraryDidChangeNotification object:nil];
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
#else
    TTLog(@"%@",[Utils documentPath]);
#endif
}

- (void)notification_iPodLibraryDidChange:(NSNotification *)notify
{
    [self.syncDataProgress show:YES];
    
    [[DataManagement sharedInstance] syncDataWithBlock:^(bool isSuccess) {
        [self.syncDataProgress hide:YES];
    }];
}

- (void)createTabViews
{
    [Utils configNavigationBar];
    [Utils configTabbarAppearce];
    
    [self setViewControllers:[self getListTabbar]];
    self.delegate = self;
    
    [self setupMoreNavVC];
    
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];
}  

- (void)setupMoreNavVC
{
    self.moreNavigationController.tabBarItem = [Utils tabbarItemWithTitle:@"More" unselectedImage:@"more.png" selectedImage:@"more-selected.png"];
    
    UITableView *moreTableView = (UITableView *)self.moreNavigationController.topViewController.view;
    if ([moreTableView isKindOfClass:[UITableView class]])
    {
        [moreTableView setTableFooterView:[UIView new]];
        self.tabBarMoreViewDelegate = [[MoreTableViewDelegate alloc] initWithForwardingDelegate:moreTableView.delegate];
        moreTableView.delegate = self.tabBarMoreViewDelegate;
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    NSMutableArray *arrayListItem = [NSMutableArray new];
    
    if (changed)
    {
        for (UINavigationController *nav in self.viewControllers)
        {
            if (nav == self.navFilesVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypeFiles]];
            }
            else if (nav == self.navSongsVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypeSongs]];
            }
            else if (nav == self.navAlbumsVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypeAlbums]];
            }
            else if (nav == self.navPlaylistsVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypePlaylists]];
            }
            else if (nav == self.navArtistsVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypeArtists]];
            }
            else if (nav == self.navGenresVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypeGenres]];
            }
            else if (nav == self.navSettingsVC) {
                [arrayListItem addObject:[NSNumber numberWithInt:kTabTypeSettings]];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:arrayListItem forKey:@"TABBAR"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray *)getListTabbar
{
    self.navFilesVC = [[UINavigationController alloc] initWithRootViewController:[[FilesViewController alloc] initWithNibName:@"FilesViewController" bundle:nil]];
    self.navFilesVC.tabBarItem = [Utils tabbarItemWithTitle:@"Files" unselectedImage:@"files.png" selectedImage:@"files-selected.png"];
    [Utils configNavigationController:self.navFilesVC];
    
    self.navSongsVC = [[UINavigationController alloc] initWithRootViewController:[[SongsViewController alloc] initWithNibName:@"SongsViewController" bundle:nil]];
    self.navSongsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Songs" unselectedImage:@"songs.png" selectedImage:@"songs-selected.png"];
    [Utils configNavigationController:self.navSongsVC];
    
    self.navAlbumsVC = [[UINavigationController alloc] initWithRootViewController:[[AlbumsViewController alloc] initWithNibName:@"AlbumsViewController" bundle:nil]];
    self.navAlbumsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Albums" unselectedImage:@"albums.png" selectedImage:@"albums-selected.png"];
    [Utils configNavigationController:self.navAlbumsVC];
    
    self.navPlaylistsVC = [[UINavigationController alloc] initWithRootViewController:[[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil]];
    self.navPlaylistsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Playlists" unselectedImage:@"playlists.png" selectedImage:@"playlists-selected.png"];
    [Utils configNavigationController:self.navPlaylistsVC];
    
    self.navArtistsVC = [[UINavigationController alloc] initWithRootViewController:[[ArtistsViewController alloc] initWithNibName:@"ArtistsViewController" bundle:nil]];
    self.navArtistsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Artists" unselectedImage:@"artists.png" selectedImage:@"artists-selected.png"];
    [Utils configNavigationController:self.navArtistsVC];
    
    self.navGenresVC = [[UINavigationController alloc] initWithRootViewController:[[GenresViewController alloc] initWithNibName:@"GenresViewController" bundle:nil]];
    self.navGenresVC.tabBarItem = [Utils tabbarItemWithTitle:@"Genres" unselectedImage:@"genres.png" selectedImage:@"genres-selected.png"];
    [Utils configNavigationController:self.navGenresVC];
    
    self.navSettingsVC = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil]];
    self.navSettingsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Settings" unselectedImage:@"settings.png" selectedImage:@"settings-selected.png"];
    [Utils configNavigationController:self.navSettingsVC];
    
    NSMutableArray *arrayListTab = [NSMutableArray new];
    
    NSArray *saveTablist = [[NSUserDefaults standardUserDefaults] objectForKey:@"TABBAR"];
    if (saveTablist && saveTablist.count == 7)
    {
        for (NSNumber *iTabType in saveTablist)
        {
            if (iTabType.intValue == kTabTypeFiles) {
                [arrayListTab addObject:self.navFilesVC];
            }
            else if (iTabType.intValue == kTabTypeSongs) {
                [arrayListTab addObject:self.navSongsVC];
            }
            else if (iTabType.intValue == kTabTypeAlbums) {
                [arrayListTab addObject:self.navAlbumsVC];
            }
            else if (iTabType.intValue == kTabTypePlaylists) {
                [arrayListTab addObject:self.navPlaylistsVC];
            }
            else if (iTabType.intValue == kTabTypeArtists) {
                [arrayListTab addObject:self.navArtistsVC];
            }
            else if (iTabType.intValue == kTabTypeGenres) {
                [arrayListTab addObject:self.navGenresVC];
            }
            else if (iTabType.intValue == kTabTypeSettings) {
                [arrayListTab addObject:self.navSettingsVC];
            }
        }
    }
    else {
        [arrayListTab addObject:self.navFilesVC];
        [arrayListTab addObject:self.navSongsVC];
        [arrayListTab addObject:self.navAlbumsVC];
        [arrayListTab addObject:self.navPlaylistsVC];
        [arrayListTab addObject:self.navArtistsVC];
        [arrayListTab addObject:self.navGenresVC];
        [arrayListTab addObject:self.navSettingsVC];
    }
    
    return [arrayListTab copy];
}

- (void)openPlayer
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[PlayerViewController sharedInstance]];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
