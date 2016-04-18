//
//  TableHeaderView.m
//  CloudMusic
//
//  Created by TuanTN on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TableHeaderView.h"

#import "TableHeaderCell.h"
#import "Utils.h"

#import "DataManagement.h"
#import "HeaderUtilObj.h"

#define SEARCHBAR_HEIGHT 50.0
#define LINE_SEPERATOR_HEIGHT 1.0

@interface TableHeaderView() <UITableViewDataSource,UITableViewDelegate>
{
    BOOL hasIndexTitles;
}

@property (nonatomic, strong) UITableView *tblListUtils;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) NSMutableArray *arrListUtils;

@end

@implementation TableHeaderView

- (NSMutableArray *)arrListUtils
{
    if (!_arrListUtils) {
        _arrListUtils = [[NSMutableArray alloc] init];
    }
    return _arrListUtils;
}

- (id)initForFilesVC
{
    self = [super init];
    
    if (self) {
        [self setupForFilesVC];
        [self initUI];
    }
    
    return self;
}

- (id)initForSongsVC
{
    self = [super init];
    
    if (self) {
        [self setupForSongsVC];
        [self initUI];
    }
    
    return self;
}

- (id)initForAlbumsVC
{
    self = [super init];
    
    if (self) {
        [self setupForAlbumsVC];
        [self initUI];
    }
    
    return self;
}

- (id)initForArtistsVC
{
    self = [super init];
    
    if (self) {
        [self setupForArtistVC];
        [self initUI];
    }
    
    return self;
}

- (id)initForGenresVC
{
    self = [super init];
    
    if (self) {
        [self setupForGenresVC];
        [self initUI];
    }
    
    return self;
}

- (id)initForPlaylistsVC
{
    self = [super init];
    
    if (self) {
        [self setupForPlaylistsVC];
        [self initUI];
    }
    
    return self;
}

- (id)initForAlbumListVC:(AlbumObj *)album
{
    self = [super init];
    
    if (self) {
        [self setupForAlbumListVC:album];
        [self initUI];
    }
    
    return self;
}

- (void)setupForFilesVC
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist]];
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Shuffle" icon:@"shuffle-icon" type:kHeaderUtilTypeShuffle]];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupForSongsVC
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist]];
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Shuffle" icon:@"shuffle-icon" type:kHeaderUtilTypeShuffle]];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
    hasIndexTitles = YES;
    
    [self setupDefault];
}

- (void)setupForAlbumsVC
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist]];
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"All Songs" icon:@"list-item-icon.png" type:kHeaderUtilTypeGoAllSongs]];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupForArtistVC
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist]];
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"All Albums" icon:@"list-item-icon.png" type:kHeaderUtilTypeGoAllAlbums]];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupForGenresVC
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist]];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupForPlaylistsVC
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"New Playlists" icon:@"add-icon" type:kHeaderUtilTypeCreateNewPlaylist]];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupForAlbumListVC:(AlbumObj *)album
{
    [self.arrListUtils removeAllObjects];
    
    [self.arrListUtils addObject:[[HeaderUtilObj alloc] initWithTitle:@"Shuffle" icon:@"shuffle-icon" type:kHeaderUtilTypeShuffle]];
    [self.arrListUtils addObject:album];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupDefault
{
    float height = 0;
    for (id item in self.arrListUtils) {
        if ([item isKindOfClass:[HeaderUtilObj class]]) {
            height += [TableHeaderCell height];
        }
        else {
            height += [MainCell largeCellHeight];
        }
    }
    height += SEARCHBAR_HEIGHT + LINE_SEPERATOR_HEIGHT;
    [self setHeight:height];
}

- (void)resignKeyboard
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
}

- (void)setHeight:(float)fHeight
{
    self.frame = CGRectMake(0.0, 0.0, DEVICE_SIZE.width, fHeight);
    [self layoutIfNeeded];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrListUtils.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.arrListUtils[indexPath.row];
    
    if ([item isKindOfClass:[HeaderUtilObj class]]) {
        return [TableHeaderCell height];
    }
    else {
        return [MainCell largeCellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.arrListUtils[indexPath.row];
    
    if ([item isKindOfClass:[HeaderUtilObj class]]) {
        TableHeaderCell *cell = (TableHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"TableHeaderCellId"];
        [cell configWithUtil:item hasIndexTitles:hasIndexTitles];
        [cell setLineHidden:(indexPath.row == self.arrListUtils.count - 1)];

        return cell;
    }
    else {
        AlbumsCell *cell = (AlbumsCell *)[tableView dequeueReusableCellWithIdentifier:@"AlbumsCellId"];
        [cell config:item];
        [cell hideExtenal];
        [cell setLineHidden:YES];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id item = self.arrListUtils[indexPath.row];
    
    if ([item isKindOfClass:[HeaderUtilObj class]]) {
        HeaderUtilObj *utilObj = (HeaderUtilObj *)item;
        if ([self.delegate respondsToSelector:@selector(selectUtility:)]) {
            [self.delegate selectUtility:utilObj.iType];
        }
    }
}

#pragma mark - InitUI

- (void)initUI
{
    //
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.searchBar];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:SEARCHBAR_HEIGHT]];
    
    [self.searchBar setBackgroundImage:[UIImage new]];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"textField-background"] forState:UIControlStateNormal];
    self.searchBar.opaque = NO;
    self.searchBar.translucent = NO;
    
    //
    self.line = [[UIView alloc] init];
    [self.line setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.line];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:LINE_SEPERATOR_HEIGHT]];
    
    //
    self.tblListUtils = [[UITableView alloc] init];
    self.tblListUtils.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tblListUtils.delegate = self;
    self.tblListUtils.dataSource = self;
    [self.tblListUtils setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.tblListUtils];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tblListUtils attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tblListUtils attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tblListUtils attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tblListUtils attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.line attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.tblListUtils setScrollEnabled:NO];
    [self.tblListUtils setTableFooterView:[UIView new]];
    
    [Utils registerNibForTableView:self.tblListUtils];
}


@end
