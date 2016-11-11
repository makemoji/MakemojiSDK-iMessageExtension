//
//  MEStickerAPIManager.h
//  Makemoji
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface MEStickerAPIManager : AFHTTPSessionManager
@property NSDate * imageViewSessionStart;
@property NSDate * clickSessionStart;
@property NSString * channel;
@property NSString * externalUserId;
@property NSMutableDictionary * imageViews;
@property NSMutableArray * emojiClicks;

+(instancetype)client;
-(void)imageViewWithId:(NSString *)emojiId;
-(void)beginImageViewSessionWithTag:(NSString *)tag;
-(void)endImageViewSession;
-(void)clickWithEmoji:(NSDictionary *)emoji;
-(void)trackShareWithEmojiId:(NSString *)emojiId;
-(NSString *)cacheNameWithChannel:(NSString *)cacheName;
+(void)setSdkKey:(NSString *)sdkKey;
@end
