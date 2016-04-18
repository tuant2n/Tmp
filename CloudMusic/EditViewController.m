//
//  EditSongViewController.m
//  CloudMusic
//
//  Created by TuanTN on 4/1/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "EditViewController.h"

#import "ArtworkView.h"

#import "TagElementCell.h"
#import "TagRenameCell.h"
#import "TagLyricCell.h"

#import "DeleteItemCell.h"
#import "WriteTagCell.h"

#import "TagObj.h"

#import "DataManagement.h"
#import "Utils.h"

#import "IQKeyboardManager.h"
#import "UIActionSheet+Blocks.h"
#import "QBImagePickerController.h"
#import "UIImage+ProportionalFill.h"

@interface EditViewController () <ArtworkViewDelegate,QBImagePickerControllerDelegate,DeleteItemCellDelegate,TagRenameCellDelegate,WriteTagCellDelegate>
{
    BOOL isWriteTagsToFile;
}

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
    
    [self.tblList registerNib:[UINib nibWithNibName:@"TagElementCell" bundle:nil] forCellReuseIdentifier:@"TagElementCellId"];
    
    [self.tblList registerNib:[UINib nibWithNibName:@"TagRenameCell" bundle:nil] forCellReuseIdentifier:@"TagRenameCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"TagLyricCell" bundle:nil] forCellReuseIdentifier:@"TagLyricCellId"];
    
    [self.tblList registerNib:[UINib nibWithNibName:@"DeleteItemCell" bundle:nil] forCellReuseIdentifier:@"DeleteItemCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"WriteTagCell" bundle:nil] forCellReuseIdentifier:@"WriteTagCellId"];
    
    [self.tblList setTableHeaderView:self.artworkView];
    [self.tblList setTableFooterView:[UIView new]];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)setupData
{
    [self.arrListTag removeAllObjects];
    isWriteTagsToFile = YES;
    
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
    writeTag.iTagType = kTagTypeWriteTags;
    writeTag.value = [NSNumber numberWithBool:isWriteTagsToFile];
    [arrSection2 addObject:writeTag];
    
    [self.arrListTag addObject:arrSection2];
    
    //
    NSMutableArray *arrSection3 = [NSMutableArray new];
    
    TagObj *file = [[TagObj alloc] init];
    file.iTagType = kTagTypeRename;
    file.value = [song.fileInfo.sFileName stringByDeletingPathExtension];
    file.isEditable = YES;
    [arrSection3 addObject:file];
    
    [self.arrListTag addObject:arrSection3];
    
    //
    NSMutableArray *arrSection4 = [NSMutableArray new];
    
    TagObj *time = [[TagObj alloc] init];
    time.iTagType = kTagTypeElement;
    time.iElementType = kElementTypeTime;
    time.value = song.sDuration;
    time.isEditable = NO;
    [arrSection4 addObject:time];
    
    TagObj *size = [[TagObj alloc] init];
    size.iTagType = kTagTypeElement;
    size.iElementType = kElementTypeSize;
    size.value = song.fileInfo.sSize;
    size.isEditable = NO;
    [arrSection4 addObject:size];
    
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
    lyric.iTagType = kTagTypeLyrics;
    lyric.value = song.sLyrics;
    lyric.isEditable = YES;
    [arrSection5 addObject:lyric];
    
    [self.arrListTag addObject:arrSection5];
    
    //
    NSMutableArray *arrSection6 = [NSMutableArray new];
    
    TagObj *delete = [[TagObj alloc] init];
    delete.iTagType = kTagTypeDelete;
    [arrSection6 addObject:delete];
    
    [self.arrListTag addObject:arrSection6];
}

- (void)getTagListFromAlbum:(AlbumObj *)albumObj
{
    //
    NSMutableArray *arrSection1 = [NSMutableArray new];
    
    TagObj *album = [[TagObj alloc] init];
    album.iTagType = kTagTypeElement;
    album.iElementType = kElementTypeAlbum;
    album.value = albumObj.sAlbumName;
    album.isEditable = YES;
    [arrSection1 addObject:album];
    
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
    writeTag.iTagType = kTagTypeWriteTags;
    writeTag.value = [NSNumber numberWithBool:isWriteTagsToFile];
    [arrSection2 addObject:writeTag];
    
    [self.arrListTag addObject:arrSection2];
    
    //
    NSMutableArray *arrSection3 = [NSMutableArray new];
    
    TagObj *delete = [[TagObj alloc] init];
    delete.iTagType = kTagTypeDelete;
    [arrSection3 addObject:delete];
    
    [self.arrListTag addObject:arrSection3];
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
    return [self.arrListTag[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.arrListTag[indexPath.section];
    TagObj *tag = data[indexPath.row];
    
    if (tag.iTagType == kTagTypeLyrics) {
        return [TagLyricCell height];
    }
    else if (tag.iTagType == kTagTypeRename) {
        return [TagRenameCell height];
    }
    return [TagElementCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.arrListTag[indexPath.section];
    TagObj *tag = data[indexPath.row];
    
    UITableViewCell *cell = nil;
    
    switch (tag.iTagType)
    {
        case kTagTypeElement:
        {
            cell = (TagElementCell *)[tableView dequeueReusableCellWithIdentifier:@"TagElementCellId" forIndexPath:indexPath];
        }
            break;
            
        case kTagTypeWriteTags:
        {
            cell = (WriteTagCell *)[tableView dequeueReusableCellWithIdentifier:@"WriteTagCellId" forIndexPath:indexPath];
        }
            break;
            
        case kTagTypeRename:
        {
            cell = (TagRenameCell *)[tableView dequeueReusableCellWithIdentifier:@"TagRenameCellId" forIndexPath:indexPath];
        }
            break;
            
        case kTagTypeLyrics:
        {
            cell = (TagLyricCell *)[tableView dequeueReusableCellWithIdentifier:@"TagLyricCellId" forIndexPath:indexPath];
        }
            break;
            
        case kTagTypeDelete:
        {
            cell = (DeleteItemCell *)[tableView dequeueReusableCellWithIdentifier:@"DeleteItemCellId" forIndexPath:indexPath];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.arrListTag[indexPath.section];
    TagObj *tag = data[indexPath.row];
    
    if ([cell isKindOfClass:[TagElementCell class]]) {
        TagElementCell *tagCell = (TagElementCell *)cell;
        [tagCell configWithTag:tag];
        [tagCell setHiddenLine:(indexPath.row == data.count - 1)];
    }
    else if ([cell isKindOfClass:[TagRenameCell class]]) {
        TagRenameCell *tagLyricCell = (TagRenameCell *)cell;
        [tagLyricCell configWithTag:tag];
        tagLyricCell.delegate = self;
    }
    else if ([cell isKindOfClass:[TagLyricCell class]]) {
        TagLyricCell *tagLyricCell = (TagLyricCell *)cell;
        [tagLyricCell configWithTag:tag];
    }
    else if ([cell isKindOfClass:[DeleteItemCell class]]) {
        DeleteItemCell *deleteSongCell = (DeleteItemCell *)cell;
        deleteSongCell.delegate = self;
    }
    else if ([cell isKindOfClass:[WriteTagCell class]]) {
        WriteTagCell *writeTagCell = (WriteTagCell *)cell;
        [writeTagCell configWithValue:isWriteTagsToFile];
        writeTagCell.delegate = self;
    }
}

#pragma mark - CellDelegate

- (void)copyTitleToFileName:(TagRenameCell *)cell;
{
    TagObj *tagObj = cell.tagObj;
    
    if (!tagObj) {
        return;
    }
    
    NSString *sSongName = nil;
    NSString *sArtistName = nil;
    
    NSIndexPath *indexPath = nil;
    
    indexPath = [self getTagWithType:kTagTypeElement elementType:kElementTypeTitle];
    if (indexPath) {
        NSArray *data = self.arrListTag[indexPath.section];
        TagObj *tag = data[indexPath.row];
        
        sSongName = tag.value;
    }
    
    indexPath = [self getTagWithType:kTagTypeElement elementType:kElementTypeArtist];
    if (indexPath) {
        NSArray *data = self.arrListTag[indexPath.section];
        TagObj *tag = data[indexPath.row];
        
        sArtistName = tag.value;
    }
    
    NSString *sTitle = nil;
    if (sArtistName && sSongName) {
        sTitle = [NSString stringWithFormat:@"%@ - %@",sArtistName,sSongName];
    }
    else {
        sTitle = sSongName;
    }
    
    tagObj.value = sTitle;
    [cell configWithTag:tagObj];
}

- (void)changeActionWriteTags:(WriteTagCell *)cell;
{
    isWriteTagsToFile = !isWriteTagsToFile;
    [cell configWithValue:isWriteTagsToFile];
}

- (void)deleteItem
{
    if (self.song) {
        [[DataManagement sharedInstance] deleteSong:self.song];
    }
    else if (self.album) {
        [[DataManagement sharedInstance] deleteAlbum:self.album];
    }
    
    [self save];
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
    
    BOOL hasImageOnClipboard = NO;
    if ([UIPasteboard generalPasteboard].image) {
        hasImageOnClipboard = YES;
    }
    
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

#pragma mark - SaveData

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
                        
                    case kElementTypeYear:
                    {
                        self.song.iYear = @([tag.value intValue]);
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else if (tag.iTagType == kTagTypeRename)
            {
                NSString *sOldName = [self.song.fileInfo.sFileName stringByDeletingPathExtension];
                NSString *sNewName = tag.value;
                
                if (![sOldName isEqualToString:sNewName])
                {
                    NSString *sExtension = @"m4a";
                    NSString *sNewFileName = [Utils getNameForFile:sNewName inFolder:[Utils dropboxPath] extension:sExtension];
                    
                    NSString *sNewFilePath = [[Utils dropboxPath] stringByAppendingPathComponent:sNewFileName];
                    NSString *sOldFilePath = [[Utils dropboxPath] stringByAppendingPathComponent:self.song.sAssetUrl];
                    
                    NSError *error = nil;
                    if ([[NSFileManager defaultManager] moveItemAtPath:sOldFilePath toPath:sNewFilePath error:&error]) {
                        self.song.fileInfo.sFileName = sNewFileName;
                        self.song.sAssetUrl = sNewFileName;
                    }
                    else {
                        NSLog(@"%@",error.description);
                    }
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

- (void)saveDataToAlbum
{
    NSFetchRequest *request = [[DataManagement sharedInstance] getListSongFilterByName:nil albumId:self.album.iAlbumId artistId:nil genreId:nil];
    NSArray *listSongs = [[[DataManagement sharedInstance] managedObjectContext] executeFetchRequest:request error:nil];
    
    if (listSongs.count <= 0) {
        [self touchCancel];
        return;
    }
    
    NSString *sAlbumName = nil;
    NSString *sArtistName = nil;
    NSString *sAlbumArtistName = nil;
    NSString *sYear = nil;
    
    for (NSArray *data in self.arrListTag)
    {
        for (TagObj *tag in data)
        {
            if (tag.iTagType == kTagTypeElement)
            {
                switch (tag.iElementType)
                {
                    case kElementTypeArtist:
                    {
                        sArtistName = tag.value;
                    }
                        break;
                        
                    case kElementTypeAlbumArtist:
                    {
                        sAlbumArtistName = tag.value;
                    }
                        break;
                        
                    case kElementTypeAlbum:
                    {
                        sAlbumName = tag.value;
                    }
                        break;
                        
                    case kElementTypeYear:
                    {
                        sYear = tag.value;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    
    // Update Year
    if ([self.album.iYear compare:@([sYear intValue])] != NSOrderedSame) {
        for (Item *song in listSongs) {
            song.iYear = @([sYear intValue]);
        }
    }
    
    if (![self.album.sAlbumName isEqualToString:sAlbumName])
    {
        NSString *iAlbumId = [[DataManagement sharedInstance] getAlbumIdFromName:sAlbumName];
        if (!iAlbumId) {
            iAlbumId = [Utils getTimestamp];
        }
        
        for (Item *song in listSongs) {
            [song setAlbumName:sAlbumName];
            song.iAlbumId = iAlbumId;
        }
    }
    
    if (![self.album.sArtistName isEqualToString:sArtistName])
    {
        NSString *iArtistId = [[DataManagement sharedInstance] getArtistIdFromName:sArtistName];
        if (!iArtistId) {
            iArtistId = [Utils getTimestamp];
        }
        
        for (Item *song in listSongs) {
            [song setArtistName:sArtistName];
            song.iArtistId = iArtistId;
        }
    }
    
    if (![self.album.sAlbumArtistName isEqualToString:sAlbumArtistName])
    {
        NSString *iAlbumArtistId = [[DataManagement sharedInstance] getAlbumArtistIdFromName:sAlbumArtistName];
        if (!iAlbumArtistId) {
            iAlbumArtistId = [Utils getTimestamp];
        }
        
        for (Item *song in listSongs) {
            [song setAlbumArtistName:sAlbumArtistName];
            song.iAlbumArtistId = iAlbumArtistId;
        }
    }
    
    if ([self.artworkView isChangeArtwork])
    {
        for (Item *song in listSongs) {
            [song setArtwork:[self.artworkView artwork]];
        }
    }
    
    [self save];
}

- (void)save
{
    [[DataManagement sharedInstance] saveData];
    [self touchCancel];
}

#pragma mark - Utils

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
