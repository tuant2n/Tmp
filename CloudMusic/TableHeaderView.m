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

@interface TableHeaderView()
{
    
}

@property (nonatomic, weak) IBOutlet UITableView *tblListUtils;
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
    [self.searchBar setBackgroundImage:[[UIImage alloc] init]];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"textField-background"] forState:UIControlStateNormal];
    self.searchBar.opaque = NO;
    self.searchBar.translucent = NO;

    [self.tblListUtils setTableFooterView:[UIView new]];
    [self.tblListUtils registerNib:[UINib nibWithNibName:@"TableHeaderCell" bundle:nil] forCellReuseIdentifier:@"TableHeaderCellId"];
}

- (void)setupForSongsVC
{
    [self.arrListUtils removeAllObjects];
    
    HeaderUtilObj *edit = [[HeaderUtilObj alloc] initWithTitle:@"Make Playlist" icon:@"edit-icon" type:kHeaderUtilTypeEdit];
    [self.arrListUtils addObject:edit];
    
    HeaderUtilObj *shuffle = [[HeaderUtilObj alloc] initWithTitle:@"Shuffle" icon:@"shuffle-icon" type:kHeaderUtilTypeShuffle];
    [self.arrListUtils addObject:shuffle];

    int numberOfRow = (int)self.arrListUtils.count;
    [self setHeight:numberOfRow * [TableHeaderCell height] + 50.0];
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
    [cell configWithUtil:utilObj];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
