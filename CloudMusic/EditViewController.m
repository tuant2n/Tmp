//
//  EditSongViewController.m
//  CloudMusic
//
//  Created by TuanTN on 4/1/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "EditViewController.h"

#import "ArtworkView.h"
#import "TagCell.h"
#import "TagLyricCell.h"
#import "TagRadioButton.h"
#import "TagButton.h"

#import "TagObj.h"

#import "DataManagement.h"
#import "Utils.h"

@interface EditViewController ()

@property (nonatomic, strong) NSMutableArray *arrListTag;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, strong) ArtworkView *artworkView;

@end

@implementation EditViewController

- (NSMutableArray *)arrListTag
{
    if (!_arrListTag) {
        _arrListTag = [[NSMutableArray alloc] init];
    }
    return _arrListTag;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
}

- (void)setupUI
{
    self.title = @"Tag Editor";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Cancel" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x006bd5 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(touchCancel)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Done" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x006bd5 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(touchDone)]];
    [Utils configNavigationController:self.navigationController];
    
    self.tblList.backgroundView = nil;
    self.tblList.backgroundColor = [Utils colorWithRGBHex:0xf0f0f0];
    self.tblList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tblList registerNib:[UINib nibWithNibName:@"TagCell" bundle:nil] forCellReuseIdentifier:@"TagCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"TagLyricCell" bundle:nil] forCellReuseIdentifier:@"TagLyricCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"TagRadioButton" bundle:nil] forCellReuseIdentifier:@"TagRadioButtonId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"TagButton" bundle:nil] forCellReuseIdentifier:@"TagButtonId"];
    
    [self.tblList setTableHeaderView:self.artworkView];
    [self.tblList setTableFooterView:[UIView new]];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)setupData
{
    [self.arrListTag removeAllObjects];
    
    if (self.song) {
        [self.artworkView setArtwotk:self.song.sLocalArtworkUrl];
        [self getTagListFromSong:self.song];
    }
    else if (self.album) {
        [self.artworkView setArtwotk:self.album.sLocalArtworkUrl];
        [self getTagListFromAlbum:self.album];
    }
    else {
        [self touchCancel];
    }
    
    [self.tblList reloadData];
}

- (void)getTagListFromSong:(Item *)song
{
    //
    NSMutableArray *arrSection1 = [NSMutableArray new];
    
    TagObj *title = [[TagObj alloc] init];
    title.iTagType = kTagTypeElement;
    title.iElementType = kElementTypeTitle;
    title.value = song.sSongName;
    title.isEditable = YES;
    [arrSection1 addObject:title];
    
    TagObj *artist = [[TagObj alloc] init];
    artist.iTagType = kTagTypeElement;
    artist.iElementType = kElementTypeArtist;
    artist.value = song.sArtistName;
    artist.isEditable = YES;
    [arrSection1 addObject:artist];
    
    TagObj *albumArtist = [[TagObj alloc] init];
    albumArtist.iTagType = kTagTypeElement;
    albumArtist.iElementType = kElementTypeAlbumArtist;
    albumArtist.value = song.sAlbumArtistName;
    albumArtist.isEditable = YES;
    [arrSection1 addObject:albumArtist];
    
    TagObj *album = [[TagObj alloc] init];
    album.iTagType = kTagTypeElement;
    album.iElementType = kElementTypeAlbum;
    album.value = song.sAlbumName;
    album.isEditable = YES;
    [arrSection1 addObject:album];
    
    TagObj *track = [[TagObj alloc] init];
    track.iTagType = kTagTypeElement;
    track.iElementType = kElementTypeTrack;
    track.value = [song.iTrack stringValue];
    track.isEditable = YES;
    [arrSection1 addObject:track];
    
    TagObj *year = [[TagObj alloc] init];
    year.iTagType = kTagTypeElement;
    year.iElementType = kElementTypeYear;
    year.value = [song.iYear stringValue];
    year.isEditable = YES;
    [arrSection1 addObject:year];
    
    TagObj *genre = [[TagObj alloc] init];
    genre.iTagType = kTagTypeElement;
    genre.iElementType = kElementTypeGenre;
    genre.value = song.sGenreName;
    genre.isEditable = YES;
    [arrSection1 addObject:genre];
    
    [self.arrListTag addObject:arrSection1];
    
    //
    NSMutableArray *arrSection2 = [NSMutableArray new];
    
    TagObj *writeTag = [[TagObj alloc] init];
    writeTag.iTagType = kTagTypeSaveToFile;
    writeTag.value = @YES;
    [arrSection2 addObject:writeTag];
    
    [self.arrListTag addObject:arrSection2];
    
    //
    NSMutableArray *arrSection3 = [NSMutableArray new];
    
    TagObj *folder = [[TagObj alloc] init];
    folder.iTagType = kTagTypeElement;
    folder.iElementType = kElementTypeFolderName;
    folder.value = song.fileInfo.sFolderName;
    folder.isEditable = NO;
    [arrSection3 addObject:folder];
    
    TagObj *file = [[TagObj alloc] init];
    file.iTagType = kTagTypeElement;
    file.iElementType = kElementTypeFilename;
    file.value = song.fileInfo.sFileName;
    file.isEditable = NO;
    [arrSection3 addObject:folder];
    
    TagObj *copyTitle = [[TagObj alloc] init];
    copyTitle.iTagType = kTagTypeAction;
    copyTitle.iTagActionType = kTagActionTypeWriteTitle;
    [arrSection3 addObject:copyTitle];
    
    [self.arrListTag addObject:arrSection3];
    
    //
    NSMutableArray *arrSection4 = [NSMutableArray new];
    
    TagObj *time = [[TagObj alloc] init];
    time.iTagType = kTagTypeElement;
    time.iElementType = kElementTypeTime;
    time.value = song.sDuration;
    time.isEditable = NO;
    [arrSection4 addObject:time];
    
    TagObj *kind = [[TagObj alloc] init];
    kind.iTagType = kTagTypeElement;
    kind.iElementType = kElementTypeKind;
    kind.value = song.fileInfo.sKind;
    kind.isEditable = NO;
    [arrSection4 addObject:kind];
    
    TagObj *size = [[TagObj alloc] init];
    size.iTagType = kTagTypeElement;
    size.iElementType = kElementTypeKind;
    size.value = song.fileInfo.sSize;
    size.isEditable = NO;
    [arrSection4 addObject:size];
    
    TagObj *biteRate = [[TagObj alloc] init];
    biteRate.iTagType = kTagTypeElement;
    biteRate.iElementType = kElementTypeBitRate;
    biteRate.value = song.fileInfo.sBitRate;
    biteRate.isEditable = NO;
    [arrSection4 addObject:biteRate];
    
    TagObj *played = [[TagObj alloc] init];
    played.iTagType = kTagTypeElement;
    played.iElementType = kElementTypePlayed;
    played.value = [song.iPlayCount stringValue];
    played.isEditable = NO;
    [arrSection4 addObject:played];
    
    [self.arrListTag addObject:arrSection4];
    
    //
    NSMutableArray *arrSection5 = [NSMutableArray new];
    
    TagObj *lyric = [[TagObj alloc] init];
    lyric.iTagType = kTagTypeElement;
    lyric.iElementType = kElementTypeLyrics;
    lyric.value = song.sLyrics;
    lyric.isEditable = YES;
    [arrSection5 addObject:lyric];
    
    [self.arrListTag addObject:arrSection5];
    
    //
    NSMutableArray *arrSection6 = [NSMutableArray new];
    
    TagObj *delete = [[TagObj alloc] init];
    delete.iTagType = kTagTypeAction;
    delete.iTagActionType = kTagActionTypeDelete;
    [arrSection6 addObject:delete];
    
    [self.arrListTag addObject:arrSection6];
}

- (void)getTagListFromAlbum:(AlbumObj *)album
{
    
}

- (void)touchCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchDone
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 10.0;
    }
    return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrListTag.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *data = self.arrListTag[section];
    return data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.arrListTag[indexPath.section];
    TagObj *tag = data[indexPath.row];
    
    if (tag.iTagType == kTagTypeElement && tag.iElementType == kElementTypeLyrics) {
        
    }
    return [TagCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.arrListTag[indexPath.section];
    TagObj *tag = data[indexPath.row];
    
    switch (tag.iTagType)
    {
        case kTagTypeElement:
        {
            if (tag.iElementType == kElementTypeLyrics) {
                TagLyricCell *cell = (TagLyricCell *)[tableView dequeueReusableCellWithIdentifier:@"TagLyricCellId" forIndexPath:indexPath];
                return cell;
            }
            else {
                TagCell *cell = (TagCell *)[tableView dequeueReusableCellWithIdentifier:@"TagCellId" forIndexPath:indexPath];
                [cell configWithTag:tag];
                [cell setHiddenLine:(indexPath.row == data.count - 1)];
                return cell;
            }
        }
            break;
            
        case kTagTypeAction:
        {
            TagButton *cell = (TagButton *)[tableView dequeueReusableCellWithIdentifier:@"TagButtonId" forIndexPath:indexPath];
            [cell configWithActionType:tag.iTagActionType];
            return cell;
        }
            break;
            
        case kTagTypeSaveToFile:
        {
            TagRadioButton *cell = (TagRadioButton *)[tableView dequeueReusableCellWithIdentifier:@"TagRadioButtonId" forIndexPath:indexPath];
            [cell configWithValue:[tag.value boolValue]];
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UI

- (ArtworkView *)artworkView
{
    if (!_artworkView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ArtworkView" owner:self options:nil];
        if ([nib count] > 0) {
            _artworkView = [nib objectAtIndex:0];
        }
    }
    return _artworkView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
