//
//  SearchDisplayController.m
//  CloudMusic
//
//  Created by TuanTN on 3/29/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SearchDisplayController.h"

@implementation SearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    if(self.active == visible) return;
    [self.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    if (visible) {
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
    }
}


@end
