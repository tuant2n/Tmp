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
    long lastTimeAppSync = 0;//[[GlobalParameter sharedInstance] lastTimeAppSync];
    long lastTimeDeviceSync = [[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSince1970];
    
    if (lastTimeAppSync != lastTimeDeviceSync)
    {
        [self syncData:lastTimeDeviceSync];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_iPodLibraryDidChange:) name: MPMediaLibraryDidChangeNotification object:nil];
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
#endif
    [[GlobalParameter sharedInstance] setupData];
}

- (void)notification_iPodLibraryDidChange:(NSNotification *)notify
{
    long lastTimeDeviceSync = [[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSince1970];
    [self syncData:lastTimeDeviceSync];
}

- (void)syncData:(long)timestamp
{
    NSMutableArray *arrListSong = [[NSMutableArray alloc] init];
    
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
    MPMediaPropertyPredicate *mediaPredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType comparisonType:MPMediaPredicateComparisonContains];
    [mediaQuery addFilterPredicate:mediaPredicate];
    
    for (MPMediaItem *song in [mediaQuery items])
    {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        [songInfo setObject:song.itemPersistentID forKey:@"iSongId"];
        [songInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isDownloaded"];
        
        if (song.itemTitle)
        {
            [songInfo setObject:song.itemTitle forKey:@"sSongTitle"];
        }
        
        if (song.itemAssetURL)
        {
            [songInfo setObject:song.itemAssetURL forKey:@"sAssetUrl"];
        }
        
        [songInfo setObject:song.itemPlayCount forKey:@"iPlayCount"];
        [songInfo setObject:song.itemRating forKey:@"iRating"];
        [songInfo setObject:song.itemPlaybackDuration forKey:@"fDuration"];
        
        if (song.itemLyrics) {
            [songInfo setObject:song.itemLyrics forKey:@"sLyrics"];
        }
        
        UIImage *artwork = [song.itemArtwork imageWithSize:song.itemArtwork.bounds.size];
        if (artwork) {
            NSString *sArtworkName = [NSString stringWithFormat:@"%@.png",song.itemPersistentID];
            BOOL isSaveArtwork = [UIImagePNGRepresentation(artwork) writeToFile:[[Utils artworkPath] stringByAppendingPathComponent:sArtworkName] atomically:YES];
            
            if (isSaveArtwork) {
                [songInfo setObject:sArtworkName forKey:@"sArtworkName"];
            }
        }
        
        [songInfo setObject:song.year forKey:@"iYear"];
        
        [songInfo setObject:song.itemAlbumTrackNumber forKey:@"iTrack"];
        [songInfo setObject:song.itemAlbumTrackCount forKey:@"iTrackCount"];
        
        [songInfo setObject:song.itemArtistPID forKey:@"iArtistId"];
        if (song.itemArtist)
        {
            [songInfo setObject:song.itemArtist forKey:@"sArtist"];
        }
        
        [songInfo setObject:song.itemAlbumPID forKey:@"iAlbumId"];
        if (song.itemAlbumTitle)
        {
            [songInfo setObject:song.itemAlbumTitle forKey:@"sAlbumTitle"];
        }
        
        [songInfo setObject:song.itemAlbumArtistPID forKey:@"iAlbumArtistId"];
        if (song.itemAlbumArtist)
        {
            [songInfo setObject:song.itemAlbumArtist forKey:@"sAlbumArtist"];
        }
        
        [songInfo setObject:song.itemGenrePID forKey:@"iGenreId"];
        if (song.itemGenre)
        {
            [songInfo setObject:song.itemGenre forKey:@"sGenre"];
        }
        
        [arrListSong addObject:songInfo];
    }
    
    for (int i = 0; i < 1000; i++) {
        NSManagedObjectContext *backgroundContext = [[DataManagement sharedInstance].coreDataController createChildContextWithType:NSPrivateQueueConcurrencyType];
        [backgroundContext performBlock:^{
            
            //        Person *person = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Person class]) inManagedObjectContext:backgroundContext];
            //        person.firstName = [NSString stringWithFormat:@"First Name %d", arc4random()];
            //        person.lastName = [NSString stringWithFormat:@"Last Name %d", arc4random()];
            //
            /* Save child context */
            [backgroundContext save:nil];
            
            NSLog(@"_____%d",i);
            
            /* Save data to store */
            [[DataManagement sharedInstance] saveData];
        }];
    }

    
    [[GlobalParameter sharedInstance] saveData:arrListSong];
    [[GlobalParameter sharedInstance] setLastTimeAppSync:timestamp];
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
