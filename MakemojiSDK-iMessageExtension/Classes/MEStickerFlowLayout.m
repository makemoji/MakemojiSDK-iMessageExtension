//
//  MEStickerFlowLayout.m
//  MakemojiSDKDemo
//
//  Created by steve on 11/10/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEStickerFlowLayout.h"

@implementation MEStickerFlowLayout

-(id)init {
    if (!(self = [super init])) return nil;
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGFloat width = frame.size.width;
    if (width > frame.size.height) { width = frame.size.height; }
    self.itemSize = CGSizeMake(width/7,34);
    [self setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 16;
    self.sectionHeadersPinToVisibleBounds = YES;
    self.headerReferenceSize = CGSizeMake(frame.size.width, 24);
    
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
