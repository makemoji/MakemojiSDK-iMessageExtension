//
//  MEStickerCollectionReusableView.m
//  MakemojiSDKDemo
//
//  Created by steve on 11/10/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEStickerCollectionReusableView.h"

@implementation MEStickerCollectionReusableView

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
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.backgroundColor = [UIColor clearColor];
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView * blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:blurEffectView];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }

    self.sectionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:self.sectionLabel];
    self.sectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sectionLabel.text = @"";
    self.sectionLabel.textColor = [UIColor colorWithWhite:0.67 alpha:1];
    self.sectionLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.topAnchor constraintEqualToAnchor:self.sectionLabel.topAnchor].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:self.sectionLabel.bottomAnchor].active = YES;
    [self.leftAnchor constraintEqualToAnchor:self.sectionLabel.leftAnchor].active = YES;
    [self.rightAnchor constraintEqualToAnchor:self.sectionLabel.rightAnchor].active = YES;
}

-(void)prepareForReuse {
    self.sectionLabel.attributedText = nil;
}

@end
