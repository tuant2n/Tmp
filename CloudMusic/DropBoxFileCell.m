//
//  DropBoxFileCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxFileCell.h"

#import "DropBoxObj.h"
#import "Utils.h"

@interface DropBoxFileCell()
{
    UIImage *folder, *mp3, *m4a, *wma, *wav, *aac, *ogg;
    UIImage *select, *unselect;
    
    UIColor *bgColor, *highlightColor;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;
@property (nonatomic, weak) IBOutlet UILabel *lblName, *lblDesc;
@property (nonatomic, weak) IBOutlet UIButton *btnCheck;
@property (nonatomic, weak) IBOutlet UIImageView *imgvFolderIcon;

@property (nonatomic, weak) IBOutlet UIView *vBackground;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lblNameHeight;

@property (nonatomic, strong) DropBoxObj *currentItem;

@end

@implementation DropBoxFileCell

- (void)awakeFromNib
{
    folder = [UIImage imageNamed:@"folder"];
    mp3 = [UIImage imageNamed:@"mp3"];
    m4a = [UIImage imageNamed:@"m4a"];
    wma = [UIImage imageNamed:@"wma"];
    wav = [UIImage imageNamed:@"wav"];
    aac = [UIImage imageNamed:@"aac"];
    ogg = [UIImage imageNamed:@"ogg"];
    
    select = [UIImage imageNamed:@"select"];
    unselect = [UIImage imageNamed:@"unselect"];
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils colorWithRGBHex:0xe4f2ff];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.lblDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configWithItem:(DropBoxObj *)item
{
    self.currentItem = item;
    
    self.lblName.text = self.currentItem.sFileName;
    self.imgvIcon.image = [self getIconWithType:self.currentItem.iType];
    
    if (self.currentItem.sDesc) {
        self.lblDesc.text = self.currentItem.sDesc;
        [self.lblNameHeight setConstant:20.0];
    }
    else {
        self.lblDesc.text = nil;
        [self.lblNameHeight setConstant:33.0];
    }
    
    if (self.currentItem.isDirectory) {
        self.imgvFolderIcon.hidden = NO;
        self.btnCheck.hidden = YES;
    }
    else {
        self.imgvFolderIcon.hidden = YES;
        self.btnCheck.hidden = NO;
    }
    
    [self setIsSelected:self.currentItem.isSelected];
    [self addObserver];
}

- (void)setIsSelected:(BOOL)isSelected
{
    [self.btnCheck setImage:(isSelected ? select:unselect) forState:UIControlStateNormal];
}

- (IBAction)touchSelect:(id)sender
{
    if (!self.currentItem) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
        [self.delegate didSelectItem:self.currentItem];
    }
}

#pragma mark - KVO

- (void)addObserver
{
    if (!self.currentItem) {
        return;
    }
    
    [self.currentItem addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserver
{
    if (!self.currentItem) {
        return;
    }
    
    [self.currentItem removeObserver:self forKeyPath:@"isSelected"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![object isKindOfClass:[DropBoxObj class]] && [keyPath isEqualToString:@"isSelected"]) {
        return;
    }
    
    [self setIsSelected:self.currentItem.isSelected];
}

- (void)dealloc
{
    [self removeObserver];
}

#pragma mark - Utils

- (UIImage *)getIconWithType:(kFileType)iType
{
    switch (iType)
    {
        case kFileTypeFolder:
            return folder;
            break;
            
        case kFileTypeMP3:
            return mp3;
            break;
            
        case kFileTypeM4A:
            return m4a;
            break;
            
        case kFileTypeWMA:
            return wma;
            break;
            
        case kFileTypeWAV:
            return wav;
            break;
            
        case kFileTypeAAC:
            return aac;
            break;
            
        case kFileTypeOGG:
            return ogg;
            break;
            
        default:
            return nil;
            break;
    }
}

+ (CGFloat)height
{
    return 52.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.vBackground.backgroundColor = highlightColor;
    }
    else {
        self.vBackground.backgroundColor = bgColor;
    }
}

@end
