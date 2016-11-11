//
//  MEStickerCollectionViewCell.m
//  MakemojiSDKDemo
//
//  Created by steve on 11/9/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEStickerCollectionViewCell.h"
#import "MEStickerAPIManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MEStickerCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    self.stickerView = [[MSStickerView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.stickerView];
    self.stickerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stickerView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSticker:)];
    tapGesture.delegate = self;
    [self.stickerView addGestureRecognizer:tapGesture];
    
    [self.contentView.topAnchor constraintEqualToAnchor:self.stickerView.topAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.stickerView.bottomAnchor].active = YES;
    [self.contentView.leftAnchor constraintEqualToAnchor:self.stickerView.leftAnchor].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.stickerView.rightAnchor].active = YES;
}

-(void)didTapSticker:(UITapGestureRecognizer *)recognizer {
    [[MEStickerAPIManager manager] trackShareWithEmojiId:self.emojiId];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


-(void)prepareForReuse {
    self.stickerView.sticker = nil;
    self.emojiId = nil;
}

@end
