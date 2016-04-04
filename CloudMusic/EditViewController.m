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

#import "TagObj.h"
#import "DataObj.h"

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
}

- (void)setupUI
{
    self.title = @"Tag Editor";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Cancel" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x006bd5 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(touchCancel)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Done" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x006bd5 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(touchDone)]];
    [Utils configNavigationController:self.navigationController];
    
    self.tblList.backgroundView = nil;
    self.tblList.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
    
    [self.tblList registerNib:[UINib nibWithNibName:@"TagCell" bundle:nil] forCellReuseIdentifier:@"TagCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"ArtworkCell" bundle:nil] forCellReuseIdentifier:@"ArtworkCellId"];
    
    self.tblList.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tblList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tblList setTableHeaderView:self.artworkView];
    [self.tblList setTableFooterView:[UIView new]];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)setupData
{
    if (self.song) {
        [self getTagListFromSong:self.song];
    }
    else if (self.album) {
        [self getTagListFromAlbum:self.album];
    }
    else {
        [self touchCancel];
    }
}

- (void)getTagListFromSong:(Item *)song
{
    
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
    DataObj *data = self.arrListTag[section];
    return data.listData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TagCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagCell *cell = (TagCell *)[tableView dequeueReusableCellWithIdentifier:@"TagCellId" forIndexPath:indexPath];
    return cell;
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
