//
//  MEMessagesViewController.m
//
//  Created by steve on 10/13/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MEMessagesViewController.h"
#import "MEStickerAPIManager.h"
#import "MEStickerFlowLayout.h"
#import "MEStickerCollectionViewCell.h"
#import "MEStickerCollectionReusableView.h"
#import "MSStickerView+WebCache.h"

@interface MEMessagesViewController ()
@property NSURLSessionDataTask * emojiWallTask;
@end

@implementation MEMessagesViewController
@synthesize categories = _categories;
@synthesize allEmoji = _allEmoji;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shareText = @"Check out the Makemoji SDK: http://makemoji.com";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.placeholderSticker = [[MSSticker alloc] initWithContentsOfFileURL:[[NSBundle mainBundle] URLForResource:@"MEPlaceholder@2x" withExtension:@"png" subdirectory:nil localization:nil] localizedDescription:@"Placeholder" error:nil];
    
    // setup share button
    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.shareButton setTitle:@"SHARE" forState:UIControlStateNormal];
    [self.shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [self.shareButton addTarget:self action:@selector(shareKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    [self.shareButton sizeToFit];
    self.shareButton.frame = CGRectMake((self.view.frame.size.width-self.shareButton.frame.size.width-10), 0, self.shareButton.frame.size.width, 24);

    // offline error view
    self.accessLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.accessLabel.backgroundColor = [UIColor colorWithWhite:0.97 alpha:0.95];
    self.accessLabel.text = @"An internet connection is required to use this extension.";
    self.accessLabel.textColor = [UIColor blackColor];
    self.accessLabel.numberOfLines = 2;
    self.accessLabel.font = [UIFont boldSystemFontOfSize:18];
    self.accessLabel.textAlignment = NSTextAlignmentCenter;
    self.accessLabel.hidden = YES;
    self.accessLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.accessLabel];
    [self.view sendSubviewToBack:self.accessLabel];
    [self.view.topAnchor constraintEqualToAnchor:self.accessLabel.topAnchor].active = YES;
    [self.view.bottomAnchor constraintEqualToAnchor:self.accessLabel.bottomAnchor].active = YES;
    [self.view.leftAnchor constraintEqualToAnchor:self.accessLabel.leftAnchor].active = YES;
    [self.view.rightAnchor constraintEqualToAnchor:self.accessLabel.rightAnchor].active = YES;
    
    // setup collection view
    MEStickerFlowLayout * stickerLayout = [[MEStickerFlowLayout alloc] init];
    self.stickerBrowser = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:stickerLayout];
    self.stickerBrowser.delegate = self;
    self.stickerBrowser.dataSource = self;
    self.stickerBrowser.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stickerBrowser registerClass:[MEStickerCollectionViewCell class] forCellWithReuseIdentifier:@"Emoji"];
    [self.stickerBrowser registerClass:[MEStickerCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section"];
    self.stickerBrowser.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    [self.view addSubview:self.stickerBrowser];
    [self.view.topAnchor constraintEqualToAnchor:self.stickerBrowser.topAnchor].active = YES;
    [self.view.bottomAnchor constraintEqualToAnchor:self.stickerBrowser.bottomAnchor].active = YES;
    [self.view.leftAnchor constraintEqualToAnchor:self.stickerBrowser.leftAnchor].active = YES;
    [self.view.rightAnchor constraintEqualToAnchor:self.stickerBrowser.rightAnchor].active = YES;
    
    [self.view bringSubviewToFront:self.shareButton];

    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.accessLabel setHidden:YES];
            [self.view sendSubviewToBack:self.accessLabel];
        } else {
            if (self.categories.count == 0 && self.allEmoji.allKeys.count == 0) {
                [self.accessLabel setHidden:NO];
                [self.view bringSubviewToFront:self.accessLabel];
            }
        }
    }];
    
    [self loadFromDisk:[[MEStickerAPIManager client] cacheNameWithChannel:@"categories"]];
    [self loadFromDisk:[[MEStickerAPIManager client] cacheNameWithChannel:@"wall"]];
    [self updateData];
    
}

- (void)updateData {
    NSString * url = @"emoji/categories";
    MEStickerAPIManager * manager = [MEStickerAPIManager client];
    
    __weak MEMessagesViewController * weakSelf = self;
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[self applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEStickerAPIManager client] cacheNameWithChannel:@"categories"]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:jsonData
                                              attributes:nil];
        weakSelf.categories = responseObject;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    self.emojiWallTask = [manager GET:@"emoji/emojiWall/imex" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:kNilOptions error:&error];
        NSString *path = [[weakSelf applicationDocumentsDirectory].path
                          stringByAppendingPathComponent:[[MEStickerAPIManager client] cacheNameWithChannel:@"wall"]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:jsonData
                                              attributes:nil];
        
        weakSelf.allEmoji = responseObject;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (NSMutableArray *)categories {
    if (_categories == nil) {
        _categories = [NSMutableArray array];
    }
    return _categories;
}

- (void)setCategories:(NSMutableArray *)categories {
    _categories = [NSMutableArray arrayWithArray:categories];
    [_categories insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Trending",@"name", nil] atIndex:0];
}

- (NSDictionary *)allEmoji {
    if (_allEmoji == nil) {
        _allEmoji = [NSDictionary dictionary];
    }
    return _allEmoji;
}

- (void)setAllEmoji:(NSDictionary *)allEmoji {
    _allEmoji = allEmoji;
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    [self.stickerBrowser reloadData];
    [UIView setAnimationsEnabled:animationsEnabled];
}

- (void)shareKeyboard {
    [[MEStickerAPIManager manager] trackShareWithEmojiId:@"0"];
    [self.activeConversation insertText:self.shareText completionHandler:nil];
}


#pragma mark - Collection View data source

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // not called
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.categories count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  [[self.allEmoji objectForKey:[self categoryNameForSection:section]] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MEStickerCollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Section" forIndexPath:indexPath];
        NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentJustified;
        style.firstLineHeadIndent = 10.0f;
        style.headIndent = 10.0f;
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:[[self categoryNameForSection:indexPath.section] uppercaseString] attributes:@{ NSParagraphStyleAttributeName : style}];
        headerView.sectionLabel.attributedText = attrText;
        reusableview = headerView;
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MEStickerCollectionViewCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Emoji" forIndexPath:indexPath];
    NSDictionary * emoji = [[self emojiArrayForSection:indexPath.section] objectAtIndex:indexPath.item];
    NSString * imageUrl = [emoji objectForKey:@"image_url"];
    [collectionCell.stickerView sd_setStickerWithURL:[NSURL URLWithString:imageUrl] placeholderSticker:self.placeholderSticker options:0 progress:nil completed:nil];
    [[MEStickerAPIManager manager] imageViewWithId:[emoji objectForKey:@"id"]];
    collectionCell.emojiId = [emoji objectForKey:@"id"];
    return collectionCell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) { return UIEdgeInsetsMake(0, 0, 14, 0); }
    return UIEdgeInsetsMake(4, 0, 14, 0);
}

#pragma mark - Conversation Handling

- (void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    [[MEStickerAPIManager manager] beginImageViewSessionWithTag:@"imex"];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)willResignActiveWithConversation:(MSConversation *)conversation {
    [[MEStickerAPIManager manager] endImageViewSession];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark - Utility

- (void)loadFromDisk:(NSString *)filename {
    NSString *path = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:filename];
    NSError * error;
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    if (data != nil) {
        id jsonResponse = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                          options:kNilOptions
                                                            error:&error];
        if (jsonResponse != nil) {
            if ([filename containsString:@"wall"]) {
                self.allEmoji = jsonResponse;
            }
            
            if ([filename containsString:@"categories"]) {
                self.categories = jsonResponse;
            }
            
        }
    }
    
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)categoryNameForSection:(NSInteger)section {
    return [[self.categories objectAtIndex:section] objectForKey:@"name"];
}

- (NSArray *)emojiArrayForSection:(NSInteger)section {
    return [self.allEmoji objectForKey:[self categoryNameForSection:section]];
}

@end
