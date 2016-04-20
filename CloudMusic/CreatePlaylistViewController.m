//
//  AddToPlaylistViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/15/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "CreatePlaylistViewController.h"

#import "DataManagement.h"
#import "GlobalParameter.h"
#import "Utils.h"

#import "PlaylistNameView.h"
#import "PlaylistCell.h"

#import "IQKeyboardManager.h"

@interface CreatePlaylistViewController() <PlaylistNameViewDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) NSMutableArray *arrPlaylists;

@property (nonatomic, strong) UIButton *btnCancel, *btnDone;
@property (nonatomic, strong) PlaylistNameView *nameView;

@end

@interface CreatePlaylistViewController ()

@end

@implementation CreatePlaylistViewController

- (NSMutableArray *)arrPlaylists
{
    if (!_arrPlaylists) {
        _arrPlaylists = [[NSMutableArray alloc] init];
    }
    return _arrPlaylists;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self getData];
}

- (void)getData
{
    [self.arrPlaylists removeAllObjects];
    
    NSFetchRequest *request = [[DataManagement sharedInstance] getListPlaylistIsGetNormalOnly:YES];
    [self.arrPlaylists addObjectsFromArray:[[DataManagement sharedInstance].managedObjectContext executeFetchRequest:request error:nil]];
    [self.tblList reloadData];
    
    if (self.arrPlaylists.count <= 0) {
        [self.nameView configWhenEmpty:YES];
        [self.tblList setTableFooterView:[UIView new]];
    }
    else {
        [self.nameView configWhenEmpty:NO];
        [self.tblList setTableFooterView:[Utils bottomLine]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [self.nameView closeKeyboard];
}

- (void)setupUI
{
    self.title = @"Playlists";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnCancel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnDone];
    
    [self setEnableDoneButton:NO];
    
    self.tblList.backgroundView = nil;
    self.tblList.backgroundColor = [Utils colorWithRGBHex:0xf0f0f0];

    [self.tblList registerNib:[UINib nibWithNibName:@"PlaylistCell" bundle:nil] forCellReuseIdentifier:@"PlaylistCellId"];
    self.tblList.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tblList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tblList setTableHeaderView:self.nameView];
    [self.tblList setTableFooterView:[UIView new]];
}

#pragma mark - PlaylistNameViewDelegate

- (void)didEnterName:(NSString *)sPlaylistName
{
    [self setEnableDoneButton:sPlaylistName.length > 0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrPlaylists.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PlaylistCell heigth];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (PlaylistCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaylistCellId" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[PlaylistCell class]]) {
        return;
    }
    
    PlaylistCell *playlistCell = (PlaylistCell *)cell;
    
    Playlist *playlist = self.arrPlaylists[indexPath.row];
    [playlistCell configWithPlaylist:playlist];
    [playlistCell setLineHidden:(indexPath.row == self.arrPlaylists.count - 1)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Playlist *playlist = self.arrPlaylists[indexPath.row];
    [self addToPlayList:playlist];
}

#pragma mark - CreateNewPlaylist

- (NSArray *)getAddList
{
    NSMutableArray *arrListSong = [NSMutableArray new];
    
    if (self.value) {
        if ([self.value isKindOfClass:[Item class]]) {
            [arrListSong addObject:self.value];
        }
        else if ([self.value isKindOfClass:[File class]]) {
            File *file = (File *)self.value;
            [arrListSong addObject:file.item];
        }
        else if ([self.value isKindOfClass:[AlbumObj class]]) {
            AlbumObj *album = (AlbumObj *)self.value;
            NSArray *arrTmp = [[DataManagement sharedInstance] getListSongFilterByName:nil albumId:album.iAlbumId artistId:nil genreId:nil];
            [arrListSong addObjectsFromArray:arrTmp];
        }
        else if ([self.value isKindOfClass:[AlbumArtistObj class]]) {
            AlbumArtistObj *albumArtist = (AlbumArtistObj *)self.value;
            NSArray *arrTmp = [[DataManagement sharedInstance] getListSongFilterByName:nil albumId:nil artistId:albumArtist.iAlbumArtistId genreId:nil];
            [arrListSong addObjectsFromArray:arrTmp];
        }
        else if ([self.value isKindOfClass:[GenreObj class]]) {
            GenreObj *genre = (GenreObj *)self.value;
            NSArray *arrTmp = [[DataManagement sharedInstance] getListSongFilterByName:nil albumId:nil artistId:nil genreId:genre.iGenreId];
            [arrListSong addObjectsFromArray:arrTmp];
        }
    }
    else if (self.listSong) {
        [arrListSong addObjectsFromArray:self.listSong];
    }
    
    return [arrListSong copy];
}

- (void)createNewPlaylist
{
    NSString *sPlaylistName = [self.nameView getPlaylistName];
    
    if (!sPlaylistName || sPlaylistName.length <= 0) {
        [self dismissView];
        return;
    }
    
    NSMutableArray *arrListSong = [[NSMutableArray alloc] initWithArray:[self getAddList]];
    if (arrListSong.count <= 0) {
        [self dismissView];
        return;
    }
    
    Playlist *playlist = [[DataManagement sharedInstance] createPlaylistWithName:sPlaylistName type:kPlaylistTypeNormal];
    [playlist addSongs:arrListSong];
    [[DataManagement sharedInstance] saveData:NO];
    [self dismissView];
}

- (void)addToPlayList:(Playlist *)playlist
{
    NSMutableArray *arrListSong = [[NSMutableArray alloc] initWithArray:[self getAddList]];
    if (arrListSong.count <= 0) {
        [self dismissView];
        return;
    }
    
    [playlist addSongs:arrListSong];
    [[DataManagement sharedInstance] saveData:NO];
    [self dismissView];
}

#pragma mark - UI

- (UIButton *)btnDone
{
    if (!_btnDone) {
        _btnDone = [Utils createBarButtonWithTitle:@"Done" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(touchDone)];
        [_btnDone setFrame:CGRectMake(_btnDone.frame.origin.x, _btnDone.frame.origin.y, 100.0, _btnDone.frame.size.height)];
    }
    return _btnDone;
}

- (void)touchDone
{
    [self createNewPlaylist];
}

- (UIButton *)btnCancel
{
    if (!_btnCancel) {
        _btnCancel = [Utils createBarButtonWithTitle:@"Cancel" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(touchCancel)];
        [_btnCancel setFrame:CGRectMake(_btnCancel.frame.origin.x, _btnCancel.frame.origin.y, 100.0, _btnCancel.frame.size.height)];
    }
    return _btnCancel;
}

- (void)touchCancel
{
    [self dismissView];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PlaylistNameView *)nameView
{
    if (!_nameView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistNameView" owner:self options:nil];
        if ([nib count] > 0) {
            _nameView = [nib objectAtIndex:0];
            _nameView.delegate = self;
        }
    }
    return _nameView;
}

#pragma mark - Utils

- (void)setEnableDoneButton:(BOOL)isEnable
{
    self.btnDone.enabled = isEnable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
