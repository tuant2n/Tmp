#import "MPVolumeView+ReferenceView.h"

@implementation MPVolumeView (ReferenceView)

+ (MPVolumeView *)swapWithReferenceView:(UIView *)referenceView
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:referenceView.frame];
    [volumeView sizeToFit];
    [volumeView setCenter:referenceView.center];
    [volumeView setAutoresizingMask:referenceView.autoresizingMask];
    [referenceView.superview addSubview:volumeView];
    [referenceView removeFromSuperview];
    
    return volumeView;
}

@end
