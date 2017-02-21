//
//  MEMessagesViewController.h
//
//  Created by steve on 10/13/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <Messages/Messages.h>

@interface MEMessagesViewController : MSMessagesAppViewController <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) UICollectionView * stickerBrowser;
@property (nonatomic, strong) NSString * shareText;
@property (nonatomic, strong) UIButton * shareButton;
@property (nonatomic, strong) NSMutableArray * categories;
@property (nonatomic, strong) NSDictionary * allEmoji;
@property (nonatomic, strong) MSSticker * placeholderSticker;
@property (nonatomic, strong) UILabel * accessLabel;
@property (nonatomic, strong) UISearchBar * searchBar;
@property BOOL isSearching;
@property (nonatomic, strong) NSMutableArray * searchResults;
@end
