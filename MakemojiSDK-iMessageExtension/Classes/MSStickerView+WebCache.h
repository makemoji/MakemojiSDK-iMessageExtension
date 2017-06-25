//
//  MSStickerView+WebCache.h
//  MakemojiSDKDemo
//
//  Created by steve on 11/10/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import <Availability.h>
#import <Messages/Messages.h>
#import <SDWebImage/SDWebImageCompat.h>
#import <SDWebImage/SDWebImageManager.h>

@interface MSStickerView (WebCache)

- (void)sd_setStickerWithURL:(NSURL *)url
          placeholderSticker:(MSSticker *)placeholder
                     options:(SDWebImageOptions)options
                    progress:(SDWebImageDownloaderProgressBlock)progressBlock
                   completed:(SDInternalCompletionBlock)completedBlock;
@end

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]){\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif
