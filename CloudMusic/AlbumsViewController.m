//
//  AlbumsViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumsViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

#import "PCSEQVisualizer.h"

@interface AlbumsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@end

@implementation AlbumsViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSEntityDescription *itemEntity = [[DataManagement sharedInstance] itemEntity];
        
        NSAttributeDescription *iAlbumId = [itemEntity.attributesByName objectForKey:@"iAlbumId"];
        NSAttributeDescription *sAlbumName = [itemEntity.attributesByName objectForKey:@"sAlbumName"];
        NSAttributeDescription *sArtistName = [itemEntity.attributesByName objectForKey:@"sAlbumArtistName"];
        NSAttributeDescription *iYear = [itemEntity.attributesByName objectForKey:@"iYear"];
        
        NSExpression *listSongId = [NSExpression expressionForKeyPath:@"iSongId"];
        NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[listSongId]];
        NSExpressionDescription *numberOfSong = [[NSExpressionDescription alloc] init];
        [numberOfSong setName: @"numberOfSong"];
        [numberOfSong setExpression:countExpression];
        [numberOfSong setExpressionResultType:NSInteger32AttributeType];
        
        NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
        NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
        NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
        [duration setName: @"duration"];
        [duration setExpression:sumExpression];
        [duration setExpressionResultType:NSInteger32AttributeType];
        
        NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
        NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
        [artwork setName: @"artwork"];
        [artwork setExpression:maxExpression];
        [artwork setExpressionResultType:NSStringAttributeType];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:itemEntity];
        [request setPropertiesToFetch:@[iAlbumId,sAlbumName,sArtistName,iYear,numberOfSong,duration,artwork]];
        [request setPropertiesToGroupBy:@[iAlbumId,sAlbumName,sArtistName,iYear]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sAlbumNameIndex" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        [request setResultType:NSDictionaryResultType];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DataManagement sharedInstance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];

        NSArray *fetchedObjects = [[[DataManagement sharedInstance] managedObjectContext] executeFetchRequest:request error:nil];
        NSLog(@"%lu",(unsigned long)fetchedObjects.count);
        NSLog(@"%@",fetchedObjects);
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self performFetch];
}

- (void)performFetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetch error: %@", error);
    }
}

- (void)setupUI
{
    self.title = @"Albums";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    
    [self.tblList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [item objectForKey:@"sAlbumName"];
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tblList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert: {
            [self.tblList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            
            break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tblList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            
            break;
            
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(UITableViewCell *)[self.tblList cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove: {
            [self.tblList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tblList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [self.tblList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tblList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tblList endUpdates];
}

#pragma mark - MusicEq

- (PCSEQVisualizer *)musicEq
{
    if (!_musicEq) {
        _musicEq = [[PCSEQVisualizer alloc] initWithNumberOfBars:3 barWidth:2 height:18.0 color:0x006bd5];
        _musicEq.userInteractionEnabled = NO;
    }
    return _musicEq;
}

- (UIBarButtonItem *)barMusicEq
{
    if (!_barMusicEq)
    {
        UIButton *btnEqHolder = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnEqHolder setFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
        btnEqHolder.backgroundColor = [UIColor clearColor];
        [btnEqHolder addTarget:self action:@selector(openPlayer:) forControlEvents:UIControlEventTouchUpInside];
        btnEqHolder.multipleTouchEnabled = NO;
        btnEqHolder.exclusiveTouch = YES;
        
        CGRect frame = self.musicEq.frame;
        frame.origin.x = (btnEqHolder.frame.size.width - frame.size.width);
        frame.origin.y = (btnEqHolder.frame.size.height - frame.size.height) / 2.0;
        self.musicEq.frame = frame;
        [btnEqHolder addSubview:self.musicEq];
        
        _barMusicEq = [[UIBarButtonItem alloc] initWithCustomView:btnEqHolder];
    }
    return _barMusicEq;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.musicEq stopEq:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[GlobalParameter sharedInstance] isPlay]) {
        [self.musicEq startEq];
    }
    else {
        [self.musicEq stopEq:NO];
    }
}

#pragma mark - Method

- (void)openPlayer:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
