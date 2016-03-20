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

#import "MPMediaItem+Accessors.h"
#import "HCDCoreDataStackController.h"

@interface MainTabBarController () <UITabBarControllerDelegate,UINavigationControllerDelegate>
{
    UINavigationController *navFilesVC, *navSongsVC, *navAlbumsVC, *navPlaylistsVC, *navArtists, *navGenres, *navSettingsVC;
}

@property (nonatomic, strong) MoreTableViewDelegate *tabBarMoreViewDelegate;

@end

@implementation MainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTabbar];
    [self setupData];
}

- (void)setupData
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

- (void)setupTabbar
{
    navFilesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NavFilesViewController"];
    navFilesVC.tabBarItem = [Utils tabbarItemWithTitle:@"Files" unselectedImage:@"files.png" selectedImage:@"files-selected.png"];
    
    navSongsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NavSongsViewController"];
    navSongsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Songs" unselectedImage:@"songs.png" selectedImage:@"songs-selected.png"];
    
    navAlbumsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NavAlbumsViewController"];
    navAlbumsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Albums" unselectedImage:@"albums.png" selectedImage:@"albums-selected.png"];
    
    navPlaylistsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NavPlaylistsViewController"];
    navPlaylistsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Playlists" unselectedImage:@"playlists.png" selectedImage:@"playlists-selected.png"];
    
    navArtists = [self.storyboard instantiateViewControllerWithIdentifier:@"NavArtistsViewController"];
    navArtists.tabBarItem = [Utils tabbarItemWithTitle:@"Artists" unselectedImage:@"artists.png" selectedImage:@"artists-selected.png"];
    
    navGenres = [self.storyboard instantiateViewControllerWithIdentifier:@"NavGenresViewController"];
    navGenres.tabBarItem = [Utils tabbarItemWithTitle:@"Genres" unselectedImage:@"genres.png" selectedImage:@"genres-selected.png"];
    
    navSettingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NavSettingsViewController"];
    navSettingsVC.tabBarItem = [Utils tabbarItemWithTitle:@"Settings" unselectedImage:@"settings.png" selectedImage:@"settings-selected.png"];
    
    [self setupMoreNavVC];
    
    [self setViewControllers:[NSArray arrayWithObjects:navFilesVC,navSongsVC,navAlbumsVC,navPlaylistsVC,navArtists,navGenres,navSettingsVC,nil]];
    self.delegate = self;
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
