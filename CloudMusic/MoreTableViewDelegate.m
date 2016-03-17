//
//  MoreTableViewDelegate.m
//  CloudMusic
//
//  Created by TuanTN on 3/15/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "MoreTableViewDelegate.h"

#import "Utils.h"

@interface MoreTableViewDelegate()

@property (nonatomic, strong) id<UITableViewDelegate> forwardingDelegate;

@end

@implementation MoreTableViewDelegate

- (instancetype)initWithForwardingDelegate:(id<UITableViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.forwardingDelegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([[self class] instancesRespondToSelector:aSelector]) {
        return YES;
    }
    return [self.forwardingDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.forwardingDelegate;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.forwardingDelegate respondsToSelector:_cmd]) {
        [self.forwardingDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
    
    cell.imageView.tintColor = [Utils colorWithRGBHex:0x333333];
}

@end
