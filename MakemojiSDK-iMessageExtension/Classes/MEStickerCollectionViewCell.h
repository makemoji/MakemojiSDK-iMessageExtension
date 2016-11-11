//
//  MEStickerCollectionViewCell.h
//  MakemojiSDKDemo
//
//  Created by steve on 11/9/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Messages/Messages.h>

@interface MEStickerCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>
@property (nonatomic, strong) MSStickerView * stickerView;
@property (nonatomic, weak) NSString * emojiId;
@end
