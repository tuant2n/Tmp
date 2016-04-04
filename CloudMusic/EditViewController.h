//
//  EditSongViewController.h
//  CloudMusic
//
//  Created by TuanTN on 4/1/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@class AlbumObj;

@interface EditViewController : UIViewController

@property (nonatomic, strong) Item *song;
@property (nonatomic, strong) AlbumObj *album;

@end
