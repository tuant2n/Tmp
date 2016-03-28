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

#import "MPMediaItem+Accessors.h"
#import "HCDCoreDataStackController.h"

@interface MainTabBarController () <UITabBarControllerDelegate,UINavigationControllerDelegate>
{
    
}

@property (nonatomic, strong) UINavigationController *navFilesVC, *navSongsVC, *navAlbumsVC, *navPlaylistsVC, *navArtistsVC, *navGenresVC, *navSettingsVC;
@property (nonatomic, strong) MoreTableViewDelegate *tabBarMoreViewDelegate;

@end

@implementation MainTabBarController

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
}

- (void)initData
{
#if !(TARGET_OS_SIMULATOR)
    long lastTimeAppSync = [[DataManagement sharedInstance] getLastTimeAppSync];
    long lastTimeDeviceSync = [[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSince1970];
    
    if (lastTimeAppSync != lastTimeDeviceSync)
    {
        [self syncData:lastTimeDeviceSync];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_iPodLibraryDidChange:) name: MPMediaLibraryDidChangeNotification object:nil];
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
#else
    NSLog(@"%@",[Utils documentPath]);
#endif
}

- (void)notification_iPodLibraryDidChange:(NSNotification *)notify
{
    long lastTimeDeviceSync = [[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSince1970];
    [self syncData:lastTimeDeviceSync];
}

- (void)syncData:(long)timestamp
{
    [[DataManagement sharedInstance] syncData];
    [[DataManagement sharedInstance] setLastTimeAppSync:timestamp];
}

- (void)createTabViews
{
    [Utils configNavigationBar];
    [Utils configTabbarAppearce];
    
    self.navFilesVC = [[UINavigationController alloc] initWithRootViewController:[[FilesViewController alloc] initWithNibName:@"FilesViewController" bundle:nil]];
    self.navFilesVC.navigationBar.translucent = NO;
    self.navFilesVC.navigationBar.shadowImage = [UIImage new];
    self.navFilesVC.tabBarItem = [Utils tabbarItemWithTitle:@"Files" unselectedImage:@"files.png" selectedImage:@"files-selected.png"];
    
    self.navSongsVC = [[UINavigationController alloc] initWithRootViewController:[[SongsViewController alloc] initWithNibName:@"SongsViewController" bundle:nil]];
    self.navSongsVC.navigationBar.translucent = NO;
    self.navSongsVC.navigationBar.shadowImage = [UIImage new];
    self.navSongsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Songs" unselectedImage:@"songs.png" selectedImage:@"songs-selected.png"];
    
//    self.navAlbumsVC = [[UINavigationController alloc] initWithRootViewController:[[AlbumsViewController alloc] initWithNibName:@"AlbumsViewController" bundle:nil]];
//    self.navAlbumsVC.navigationBar.translucent = NO;
//    self.navAlbumsVC.navigationBar.shadowImage = [UIImage new];
//    self.navAlbumsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Albums" unselectedImage:@"albums.png" selectedImage:@"albums-selected.png"];
    
    self.navPlaylistsVC = [[UINavigationController alloc] initWithRootViewController:[[PlaylistsViewController alloc] initWithNibName:@"PlaylistsViewController" bundle:nil]];
    self.navPlaylistsVC.navigationBar.translucent = NO;
    self.navPlaylistsVC.navigationBar.shadowImage = [UIImage new];
    self.navPlaylistsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Playlists" unselectedImage:@"playlists.png" selectedImage:@"playlists-selected.png"];

    self.navArtistsVC = [[UINavigationController alloc] initWithRootViewController:[[ArtistsViewController alloc] initWithNibName:@"ArtistsViewController" bundle:nil]];
    self.navArtistsVC.navigationBar.translucent = NO;
    self.navArtistsVC.navigationBar.shadowImage = [UIImage new];
    self.navArtistsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Artists" unselectedImage:@"artists.png" selectedImage:@"artists-selected.png"];
    
    self.navGenresVC = [[UINavigationController alloc] initWithRootViewController:[[GenresViewController alloc] initWithNibName:@"GenresViewController" bundle:nil]];
    self.navGenresVC.navigationBar.translucent = NO;
    self.navGenresVC.navigationBar.shadowImage = [UIImage new];
    self.navGenresVC.tabBarItem = [Utils tabbarItemWithTitle:@"Genres" unselectedImage:@"genres.png" selectedImage:@"genres-selected.png"];
    
    self.navSettingsVC = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil]];
    self.navSettingsVC.navigationBar.translucent = NO;
    self.navSettingsVC.navigationBar.shadowImage = [UIImage new];
    self.navSettingsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Settings" unselectedImage:@"settings.png" selectedImage:@"settings-selected.png"];
    
    [self setViewControllers:[NSArray arrayWithObjects:self.navFilesVC,self.navSongsVC,self.navPlaylistsVC,self.navArtistsVC,self.navGenresVC,self.navSettingsVC,nil]];
    [self setSelectedViewController:self.navFilesVC];
    self.delegate = self;
    
    [self setupMoreNavVC];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
