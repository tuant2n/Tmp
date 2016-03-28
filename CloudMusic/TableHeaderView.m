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

#import "HeaderUtilObj.h"

#define SEARCHBAR_HEIGHT 51.0

@interface TableHeaderView()
{
    float height;
    BOOL hasIndexTitles;
}

@property (nonatomic, weak) IBOutlet UITableView *tblListUtils;
@property (nonatomic, weak) IBOutlet UIView *line;

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI
{
    [self.searchBar setBackgroundImage:[UIImage new]];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"textField-background"] forState:UIControlStateNormal];
    self.searchBar.opaque = NO;
    self.searchBar.translucent = NO;

    [self.tblListUtils setScrollEnabled:NO];
    [self.tblListUtils setTableFooterView:[UIView new]];
    [self.tblListUtils registerNib:[UINib nibWithNibName:@"TableHeaderCell" bundle:nil] forCellReuseIdentifier:@"TableHeaderCellId"];
}

- (void)setupForSongsVC
{
    [self.arrListUtils removeAllObjects];
    
    HeaderUtilObj *edit = [[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist];
    [self.arrListUtils addObject:edit];
    
    HeaderUtilObj *shuffle = [[HeaderUtilObj alloc] initWithTitle:@"Shuffle" icon:@"shuffle-icon" type:kHeaderUtilTypeShuffle];
    [self.arrListUtils addObject:shuffle];

    self.line.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
    hasIndexTitles = YES;
    
    [self setupDefault];
}

- (void)setupForAlbumVC
{
    [self.arrListUtils removeAllObjects];
    
    HeaderUtilObj *edit = [[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist];
    [self.arrListUtils addObject:edit];
    
    HeaderUtilObj *shuffle = [[HeaderUtilObj alloc] initWithTitle:@"All Songs" icon:@"list-item-icon.png" type:kHeaderUtilTypeGoAllSongs];
    [self.arrListUtils addObject:shuffle];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupForArtistVC
{
    [self.arrListUtils removeAllObjects];
    
    HeaderUtilObj *edit = [[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeCreatePlaylist];
    [self.arrListUtils addObject:edit];
    
    HeaderUtilObj *shuffle = [[HeaderUtilObj alloc] initWithTitle:@"All Albums" icon:@"list-item-icon.png" type:kHeaderUtilTypeGoAllAlbums];
    [self.arrListUtils addObject:shuffle];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    hasIndexTitles = NO;
    
    [self setupDefault];
}

- (void)setupDefault
{
    int numberOfRow = (int)self.arrListUtils.count;
    height = numberOfRow * [TableHeaderCell height] + SEARCHBAR_HEIGHT;
    
    [self setActiveSearchBar:NO];
}

- (void)setActiveSearchBar:(BOOL)isActive
{
    if (!isActive) {
        [self setHeight:height];
    }
    else {
        [self setHeight:SEARCHBAR_HEIGHT];
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
    return [TableHeaderCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableHeaderCell *cell = (TableHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"TableHeaderCellId"];
    
    HeaderUtilObj *utilObj = self.arrListUtils[indexPath.row];
    [cell configWithUtil:utilObj hasIndexTitles:hasIndexTitles];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    HeaderUtilObj *utilObj = self.arrListUtils[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(selectUtility:)]) {
        [self.delegate selectUtility:utilObj.iType];
    }
}


@end
