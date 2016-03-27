//
//  TableHeaderView.h
//  CloudMusic
//
//  Created by TuanTN on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeaderView : UIView

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

- (void)setupForSongsVC;

- (void)setActiveSearchBar:(BOOL)isActive;
- (void)setHeight:(float)fHeight;

@end
