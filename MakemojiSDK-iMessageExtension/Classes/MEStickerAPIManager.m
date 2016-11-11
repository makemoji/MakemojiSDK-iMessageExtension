//
//  MEStickerAPIManager.m
//  MakemojiSDKDemo
//
//  Created by steve on 10/12/16.
//  Copyright © 2016 Makemoji. All rights reserved.
//

#import "MEStickerAPIManager.h"
#import <AdSupport/AdSupport.h>


@implementation MEStickerAPIManager

NSString *const kMEStickersSSLBaseUrl = @"https://api.makemoji.com/sdk/";

+(instancetype)client
{
    static MEStickerAPIManager * requests = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requests = [[MEStickerAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kMEStickersSSLBaseUrl]];
        [requests.reachabilityManager startMonitoring];
        requests.channel = @"";
        NSString * deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] == YES) {
            deviceId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        
        NSString *language = [NSLocale currentLocale].localeIdentifier;
        
        NSString *model = [[UIDevice currentDevice] name];
        if ([model isEqualToString:@"iPhone Simulator"]) { deviceId = @"SIMULATOR"; }
        [requests.requestSerializer  setValue:deviceId forHTTPHeaderField:@"makemoji-deviceId"];
        [requests.requestSerializer  setValue:language forHTTPHeaderField:@"makemoji-language"];
        [requests.requestSerializer  setValue:@"1.1" forHTTPHeaderField:@"makemoji-version"];
        
    });
    return requests;
}

-(NSString *)cacheNameWithChannel:(NSString *)cacheName {
    return [NSString stringWithFormat:@"%@-%@.json", self.channel, cacheName];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response,
                                                        id responseObject,
                                                        NSError *error))completionHandler
{
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
    if (reachability.isReachable == NO) {
        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return [super dataTaskWithRequest:modifiedRequest
                    completionHandler:completionHandler];
}



-(void)imageViewWithId:(NSString *)emojiId {
    
    MEStickerAPIManager * apiManager = [MEStickerAPIManager client];
    
    if (apiManager.imageViewSessionStart != nil) {
        if (fabs([apiManager.imageViewSessionStart timeIntervalSinceNow]) > 30) {
            [apiManager endImageViewSession];
            apiManager.imageViews = nil;
            apiManager.imageViewSessionStart = nil;
        }
    }
    
    if (apiManager.imageViews == nil) {
        apiManager.imageViews = [NSMutableDictionary dictionary];
    }
    
    if (apiManager.imageViewSessionStart == nil) {
        apiManager.imageViewSessionStart = [NSDate date];
    }
    
    NSMutableDictionary * viewDict = [apiManager.imageViews objectForKey:emojiId];
    
    if (viewDict == nil) {
        NSMutableDictionary * newDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:emojiId, @"1", nil] forKeys:[NSArray arrayWithObjects:@"emoji_id", @"views", nil]];
        [apiManager.imageViews setObject:newDict forKey:emojiId];
    } else {
        NSString * viewNumber = [viewDict objectForKey:@"views"];
        NSInteger viewCount = [viewNumber integerValue];
        viewCount++;
        [viewDict setObject:[NSString stringWithFormat:@"%li", (long)viewCount] forKey:@"views"];
        [apiManager.imageViews setObject:viewDict forKey:emojiId];
    }
}

-(void)beginImageViewSessionWithTag:(NSString *)tag {
    MEStickerAPIManager * apiManager = [MEStickerAPIManager client];
    if (apiManager.imageViewSessionStart == nil) {
        apiManager.imageViewSessionStart = [NSDate date];
    }
}

-(void)endImageViewSession {
    MEStickerAPIManager *manager = [MEStickerAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSMutableDictionary * sending = [[MEStickerAPIManager client] imageViews];
    [sending setObject:[[MEStickerAPIManager client] imageViewSessionStart] forKey:@"date"];
    manager.imageViewSessionStart = nil;
    manager.imageViews = nil;
    
    [manager POST:@"emoji/viewTrack" parameters:sending success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}


+(void)setSdkKey:(NSString *)sdkKey {
    MEStickerAPIManager * manager = [MEStickerAPIManager client];
    [manager.requestSerializer setValue:sdkKey forHTTPHeaderField:@"makemoji-sdkkey"];
}

-(void)clickWithEmoji:(NSDictionary *)emoji {
    
    MEStickerAPIManager * apiManager = [MEStickerAPIManager client];
    if (apiManager.emojiClicks == nil) {
        apiManager.emojiClicks = [NSMutableArray array];
        apiManager.clickSessionStart = [NSDate date];
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:emoji];
    
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:[NSDate date]];
    
    [dict setObject:dateString forKey:@"click"];
    NSArray * removeKeys = @[@"image_url", @"username", @"access",@"origin_id",@"likes",@"deleted",@"created",@"link_url",@"name",@"flashtag"];
    for (NSString * key in removeKeys) {
        [dict removeObjectForKey:key];
    }
    
    [apiManager.emojiClicks addObject:dict];
    
    if (apiManager.emojiClicks.count > 25) {
        NSError * error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:apiManager.emojiClicks options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [apiManager POST:@"emoji/clickTrackBatch" parameters:@{@"emoji": jsonString} success:^(NSURLSessionDataTask *task, id responseObject) {
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        apiManager.emojiClicks = nil;
        apiManager.clickSessionStart = nil;
        
    }
    
}

-(void)trackShareWithEmojiId:(NSString *)emojiId {
    MEStickerAPIManager *manager = [MEStickerAPIManager client];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString * url = [NSString stringWithFormat:@"emoji/share/0/%@/%@", emojiId, @"emoji"];

    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}



@end
