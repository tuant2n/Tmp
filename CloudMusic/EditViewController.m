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

#import "IQKeyboardManager.h"
#import "UIActionSheet+Blocks.h"
#import "QBImagePickerController.h"
#import "UIImage+ProportionalFill.h"

@interface EditViewController () <ArtworkViewDelegate,QBImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *arrListTag;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, strong) ArtworkView *artworkView;

@property (nonatomic, strong) QBImagePickerController *imagePickerController;

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
    writeTag.iTagType = kTagTypeWriteTag;
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
    [arrSection3 addObject:file];
    
    TagObj *copyTitle = [[TagObj alloc] init];
    copyTitle.iTagType = kTagTypeAction;
    copyTitle.iTagActionType = kTagActionTypeCopyTitle;
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
    
    TagObj *clearLyric = [[TagObj alloc] init];
    clearLyric.iTagType = kTagTypeAction;
    clearLyric.iTagActionType = kTagActionTypeClearLyric;
    [arrSection5 addObject:clearLyric];
    
    TagObj *lyric = [[TagObj alloc] init];
    lyric.iTagType = kTagTypeLyrics;
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

- (void)saveDataToSong
{
    for (NSArray *data in self.arrListTag)
    {
        for (TagObj *tag in data)
        {
            if (tag.iTagType == kTagTypeElement)
            {
                switch (tag.iElementType)
                {
                    case kElementTypeTitle:
                    {
                        [self.song setSongName:tag.value];
                    }
                        break;
                        
                    case kElementTypeArtist:
                    {
                        [self.song changeArtistName:tag.value];
                    }
                        break;
                        
                    case kElementTypeAlbumArtist:
                    {
                        [self.song changeAlbumArtistName:tag.value];
                    }
                        break;
                        
                    case kElementTypeAlbum:
                    {
                        [self.song changeAlbumName:tag.value];
                    }
                        break;
                        
                    case kElementTypeGenre:
                    {
                        [self.song changeGenreName:tag.value];
                    }
                        break;
                        
                    case kElementTypeTrack:
                    case kElementTypeYear:
                    {
                        self.song.iTrack = @([tag.value intValue]);
                    }
                        break;
                        
                    case kElementTypeFilename:
                    {
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else if (tag.iTagType == kTagTypeLyrics)
            {
                self.song.sLyrics = tag.value;
            }
        }
    }
    
    if ([self.artworkView isChangeArtwork]) {
        [self.song setArtwork:[self.artworkView artwork]];
    }
    
    [self save];
}

- (void)getTagListFromAlbum:(AlbumObj *)albumObj
{
    //
    NSMutableArray *arrSection1 = [NSMutableArray new];
    
    TagObj *artist = [[TagObj alloc] init];
    artist.iTagType = kTagTypeElement;
    artist.iElementType = kElementTypeArtist;
    artist.value = albumObj.sArtistName;
    artist.isEditable = YES;
    [arrSection1 addObject:artist];
    
    TagObj *albumArtist = [[TagObj alloc] init];
    albumArtist.iTagType = kTagTypeElement;
    albumArtist.iElementType = kElementTypeAlbumArtist;
    albumArtist.value = albumObj.sAlbumArtistName;
    albumArtist.isEditable = YES;
    [arrSection1 addObject:albumArtist];
    
    TagObj *album = [[TagObj alloc] init];
    album.iTagType = kTagTypeElement;
    album.iElementType = kElementTypeAlbum;
    album.value = albumObj.sAlbumName;
    album.isEditable = YES;
    [arrSection1 addObject:album];
    
    TagObj *year = [[TagObj alloc] init];
    year.iTagType = kTagTypeElement;
    year.iElementType = kElementTypeYear;
    year.value = [albumObj.iYear stringValue];
    year.isEditable = YES;
    [arrSection1 addObject:year];

    [self.arrListTag addObject:arrSection1];
    
    //
    NSMutableArray *arrSection2 = [NSMutableArray new];
    
    TagObj *writeTag = [[TagObj alloc] init];
    writeTag.iTagType = kTagTypeWriteTag;
    writeTag.value = @YES;
    [arrSection2 addObject:writeTag];
    
    [self.arrListTag addObject:arrSection2];
    
    //
    NSMutableArray *arrSection3 = [NSMutableArray new];
    
    TagObj *delete = [[TagObj alloc] init];
    delete.iTagType = kTagTypeAction;
    delete.iTagActionType = kTagActionTypeDelete;
    [arrSection3 addObject:delete];
    
    [self.arrListTag addObject:arrSection3];
}

- (void)saveDataToAlbum
{
    [self save];
}

- (void)save
{
    [[DataManagement sharedInstance] saveData];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_DATA object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchCancel
{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchDone
{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    
    if (self.song) {
        [self saveDataToSong];
    }
    else if (self.album) {
        [self saveDataToAlbum];
    }
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
    
    if (tag.iTagType == kTagTypeLyrics) {
        return [TagLyricCell height];
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
            TagCell *cell = (TagCell *)[tableView dequeueReusableCellWithIdentifier:@"TagCellId" forIndexPath:indexPath];
            [cell configWithTag:tag];
            [cell setHiddenLine:(indexPath.row == data.count - 1)];
            return cell;
        }
            break;
            
        case kTagTypeAction:
        {
            TagButton *cell = (TagButton *)[tableView dequeueReusableCellWithIdentifier:@"TagButtonId" forIndexPath:indexPath];
            [cell configWithActionType:tag.iTagActionType];
            return cell;
        }
            break;
            
        case kTagTypeWriteTag:
        {
            TagRadioButton *cell = (TagRadioButton *)[tableView dequeueReusableCellWithIdentifier:@"TagRadioButtonId" forIndexPath:indexPath];
            [cell configWithValue:[tag.value boolValue]];
            return cell;
        }
            break;
            
        case kTagTypeLyrics:
        {
            TagLyricCell *cell = (TagLyricCell *)[tableView dequeueReusableCellWithIdentifier:@"TagLyricCellId" forIndexPath:indexPath];
            [cell configWithTag:tag];
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.arrListTag[indexPath.section];
    TagObj *tag = data[indexPath.row];
    
    switch (tag.iTagType)
    {
        case kTagTypeAction:
        {
            if (tag.iTagActionType == kTagActionTypeCopyTitle)
            {
                NSIndexPath *tagIndexPath = [self getTagWithType:kTagTypeElement elementType:kElementTypeFilename];
                if (tagIndexPath)
                {
                    TagObj *tagObj = self.arrListTag[tagIndexPath.section][tagIndexPath.row];
                    tagObj.value = self.song.sSongName;
                    
                    TagCell *cell = (TagCell *)[self.tblList cellForRowAtIndexPath:tagIndexPath];
                    if (cell) {
                        [cell configWithTag:tagObj];
                    }
                }
            }
            else if (tag.iTagActionType == kTagActionTypeDelete)
            {
                [[[DataManagement sharedInstance] managedObjectContext] deleteObject:self.song];
                [self save];
            }
            else if (tag.iTagActionType == kTagActionTypeClearLyric)
            {
                NSIndexPath *tagIndexPath = [self getTagWithType:kTagTypeLyrics elementType:kElementTypeNone];
                if (tagIndexPath)
                {
                    TagObj *tagObj = self.arrListTag[tagIndexPath.section][tagIndexPath.row];
                    tagObj.value = nil;
                    
                    TagLyricCell *cell = (TagLyricCell *)[self.tblList cellForRowAtIndexPath:tagIndexPath];
                    if (cell) {
                        [cell configWithTag:tagObj];
                    }
                }
            }
        }
            break;
            
        case kTagTypeWriteTag:
        {
            BOOL isWrite = ![tag.value boolValue];
            tag.value = [NSNumber numberWithBool:isWrite];
            
            TagRadioButton *cell = (TagRadioButton *)[self.tblList cellForRowAtIndexPath:indexPath];
            if (cell) {
                [cell configWithValue:[tag.value boolValue]];
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSIndexPath *)getTagWithType:(kTagType)iTagType elementType:(kElementType)iElementType
{
    NSIndexPath *indexPath = nil;
    
    BOOL dobreak = NO;
    for (int i = 0; !dobreak && i < self.arrListTag.count; i++)
    {
        NSArray *data = self.arrListTag[i];

        for (int j = 0; j < data.count; j++)
        {
            TagObj *tag = data[j];
            
            if (tag.iTagType == iTagType && tag.iElementType == iElementType) {
                indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                dobreak = YES;
                break;
            }
        }
    }
    
    return indexPath;
}

#pragma mark - Artwotk

- (ArtworkView *)artworkView
{
    if (!_artworkView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ArtworkView" owner:self options:nil];
        if ([nib count] > 0) {
            _artworkView = [nib objectAtIndex:0];
            _artworkView.delegate = self;
        }
    }
    return _artworkView;
}

- (void)changeArtwork
{
    BOOL hasArtwork = NO;
    if ([self.artworkView artwork]) {
        hasArtwork = YES;
    }
    
    BOOL hasImageOnClipboard = [UIPasteboard generalPasteboard].image;
    
    NSMutableArray *arrayAction = [NSMutableArray new];
    [arrayAction addObject:@"Choose from Camera Roll"];
    
    if (hasArtwork) {
        [arrayAction addObject:@"Copy"];
    }
    
    if (hasImageOnClipboard) {
        [arrayAction addObject:@"Paste"];
    }
    
    [UIActionSheet showInView:self.view
                    withTitle:nil
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:(hasArtwork ? @"Delete Artwork":nil)
            otherButtonTitles:arrayAction
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex)
     {
         NSString *sTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
         
         if ([sTitle isEqualToString:@"Delete Artwork"]) {
             [self.artworkView setArtwotk:nil];
         }
         else if ([sTitle isEqualToString:@"Choose from Camera Roll"]) {
             [self presentViewController:self.imagePickerController animated:YES completion:NULL];
         }
         else if ([sTitle isEqualToString:@"Copy"]) {
             [[UIPasteboard generalPasteboard] setImage:[self.artworkView artwork]];
         }
         else if ([sTitle isEqualToString:@"Paste"]) {
             [self.artworkView setArtworkImage:[UIPasteboard generalPasteboard].image];
         }
     }];
}

#pragma mark - ImagePicker

- (QBImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController = [QBImagePickerController new];
        _imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        _imagePickerController.allowsMultipleSelection = NO;
        _imagePickerController.showsNumberOfSelectedAssets = YES;
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    UIImage *tmpImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
    UIImage *image = [tmpImage imageCroppedToFitSize:CGSizeMake(300.0, 300.0)];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.artworkView setArtworkImage:image];
    }];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
